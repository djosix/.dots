#!/usr/bin/env python3
# Author: djosix
# License: MIT

import json
import re
import os
import sys
import socket
import textwrap
import enum
import base64
import subprocess as sp
from datetime import datetime
from typing import List, NamedTuple, Optional, Union
from argparse import ArgumentParser
from contextlib import suppress

while True:
    try:
        from flask import Flask, request, abort, escape, redirect
        from flask.helpers import send_file
        from flask_httpauth import HTTPBasicAuth
        from werkzeug.serving import get_interface_ip
        from werkzeug.utils import secure_filename
        break
    except ImportError:
        if input('Install required packages? [y/N] ').lower() != 'y':
            sys.exit()
        sp.check_call([sys.executable, '-m', 'pip', 'install',
                       'flask', 'flask_httpauth', 'werkzeug'])
        continue

class TableRow(NamedTuple):
    name: str
    type: str
    last_modified_timestamp: int
    size_in_byte: Optional[int]

class EntryType(enum.Enum):
    UNKNOWN = 0
    FILE = 1
    DIRECTORY = 2

NO_CLOSING_TAGS = {
    'area',
    'base',
    'br',
    'col',
    'command',
    'embed',
    'hr',
    'img',
    'input',
    'keygen',
    'link',
    'meta',
    'param',
    'source',
    'track',
    'wbr',
}

def T(name, *args: List[Union[str, list, tuple, dict]], **kwargs) -> str:
    render_if = kwargs.pop('render_if', True)
    if not render_if:
        return ''
    
    assert len(kwargs) == 0
    
    attrs, inner = {}, []
    
    for arg in args:
        if isinstance(arg, (list, tuple)):
            inner.extend(arg)
        elif isinstance(arg, dict):
            attrs.update(arg)
        else:
            inner.append(str(arg))
    
    name_tag = re.search(r'^[^.#]*', name).group() or 'div'
    name_ids = re.findall(r'[#]([^.#]*)', name)
    name_classes = re.findall(r'[.]([^.#]*)', name)
    
    classes = attrs.get('class')
    if isinstance(classes, (list, tuple)):
        attrs['class'] = ' '.join(classes)
        
    if len(name_ids) > 0:
        assert len(name_ids) == 1
        assert attrs.get('id') is None
        attrs['id'] = name_ids[0]
        
    if len(name_classes) > 0:
        class_value = attrs.get('class')
        if class_value is not None:
            assert isinstance(class_value, str)
            attrs['class'] = ' '.join((class_value, *name_classes))
        else:
            attrs['class'] = ' '.join(name_classes)
        
    attrs = ''.join(f' {escape(key)}="{escape(value)}"' for key, value in attrs.items())
    inner = ''.join(map(str, inner))
    
    if name_tag.lower() in NO_CLOSING_TAGS:
        assert len(inner) == 0
        return f'<{escape(name_tag)}{attrs}/>'
    else:
        return f'<{escape(name_tag)}{attrs}>{inner}</{escape(name_tag)}>'

def format_date(timestamp: Union[int, float]):
    assert isinstance(timestamp, (int, float))
    return str(datetime.fromtimestamp(int(timestamp)))

def format_size(size: int) -> str:
    for unit in ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z']:
        if abs(size) < 1024.0:
            return f'{size:3.1f}{unit}'
        size /= 1024.0
    return f'{size:.1f}Y'

def sanitize_path(path):
    path = path.replace('..', '')
    path = path.replace('//', '')
    path = path.lstrip('/')
    return path

def get_path_type(path) -> EntryType:
    if os.path.exists(path):
        if os.path.isfile(path):
            return EntryType.FILE
        elif os.path.isdir(path):
            return EntryType.DIRECTORY
    return EntryType.UNKNOWN

def format_entry_name(entry):
    if entry['type'] == EntryType.FILE:
        return entry['name']
    elif entry['type'] == EntryType.DIRECTORY:
        return entry['name'] + '/'
    else:
        return entry['name'] + '?'

def format_entry_permission(entry):
    string = ''
    if entry['readable']:
        string += 'R'
    if entry['writable']:
        string += 'W'
    if string == '':
        string = '-'
    return string

def format_entry_size(entry):
    if entry['type'] == EntryType.FILE:
        return format_size(entry['stat'].st_size)
    else:
        return '-'

def get_path_readibility(path):
    type = get_path_type(path)
    if type == EntryType.FILE:
        return os.access(path, os.R_OK)
    elif type == EntryType.DIRECTORY:
        return os.access(path, os.R_OK | os.X_OK)
    return False

def get_path_writability(path):
    type = get_path_type(path)
    if type == EntryType.FILE:
        return os.access(path, os.W_OK)
    elif type == EntryType.DIRECTORY:
        return os.access(path, os.W_OK | os.R_OK | os.X_OK)
    return False

ICON_SVG_DOCUMENT = (
    '<svg fill="#000000" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="32px" height="32px">'
    '<path d="M 4.5 2 C 3.675781 2 3 2.675781 3 3.5 L 3 12.5 C 3 13.324219 3.675781 14 4.5 14 L 11.5 14 C '
    '12.324219 14 13 13.324219 13 12.5 L 13 5.292969 L 9.707031 2 Z M 4.5 3 L 9 3 L 9 6 L 12 6 L 12 12.5 C '
    '12 12.78125 11.78125 13 11.5 13 L 4.5 13 C 4.21875 13 4 12.78125 4 12.5 L 4 3.5 C 4 3.21875 4.21875 3 '
    '4.5 3 Z M 10 3.707031 L 11.292969 5 L 10 5 Z M 6 8 L 6 9 L 10 9 L 10 8 Z M 6 10 L 6 11 L 9 11 L 9 10 Z"/></svg>'
)
ICON_SVG_FOLDER = (
    '<svg fill="#000000" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="32px" height="32px">'
    '<path d="M 2.5 2 C 1.675781 2 1 2.675781 1 3.5 L 1 12.5 C 1 13.324219 1.675781 14 2.5 14 L 13.5 14 C 14.324219 '
    '14 15 13.324219 15 12.5 L 15 5.5 C 15 4.675781 14.324219 4 13.5 4 L 6.796875 4 L 6.144531 2.789063 C 5.882813 '
    '2.300781 5.375 2 4.824219 2 Z M 2.5 3 L 4.824219 3 C 5.007813 3 5.175781 3.101563 5.265625 3.261719 L 5.664063 '
    '4 L 2 4 L 2 3.5 C 2 3.21875 2.21875 3 2.5 3 Z M 2 5 L 13.5 5 C 13.78125 5 14 5.21875 14 5.5 L 14 12.5 C 14 12.78125 '
    '13.78125 13 13.5 13 L 2.5 13 C 2.21875 13 2 12.78125 2 12.5 Z"/></svg>'
)

def base64_encode(s):
    return base64.b64encode(s.encode()).decode()

def svg_img(svg_data):
    return T('img', {
        'src': 'data:image/svg+xml;base64,{}'.format(base64_encode(svg_data)),
        'style': 'width: 16px',
    })

class Handler:
    def __init__(self, root, no_list, no_modify):
        self.abs_root = os.path.abspath(root)
        self.no_list = no_list
        self.no_modify = no_modify
    
    def __get_local_path(self, path):
        abs_path = os.path.abspath(os.path.join(self.abs_root, path))
        if abs_path.startswith(self.abs_root):
            return abs_path

    def __list_directory(self, abs_dir_path):
        
        relpath = os.path.relpath(abs_dir_path, self.abs_root)
        webpath = os.path.join('/', relpath)
        webpath = os.path.abspath(webpath)
        
        dir_writable = os.access(abs_dir_path, os.W_OK)
        
        entries = []
        
        for item_name in os.listdir(abs_dir_path):
            item_path = os.path.join(abs_dir_path, item_name)
            with suppress(Exception):
                entries.append({
                    'name': item_name,
                    'path': item_path,
                    'type': get_path_type(item_path),
                    'readable': get_path_readibility(item_path),
                    'writable': get_path_writability(item_path),
                    'stat': os.stat(item_path),
                })
        
        entries.sort(key=(lambda entry: (-entry['type'].value, entry['name'])))
        
        href_tokens = []
        breadcrumb_links = [T('a', {'href': '/'}, 'Home')]
        for token in filter(len, webpath.split('/')):
            href_tokens.append(token)
            breadcrumb_links.append(T('a', {'href': '/' + '/'.join(href_tokens)}, token))
        
        icon_map = {
            EntryType.FILE: svg_img(ICON_SVG_DOCUMENT),
            EntryType.DIRECTORY: svg_img(ICON_SVG_FOLDER),
        }
        
        table_rows = []
        for i, entry in enumerate(entries):
            link_attrs = {}
            if entry['readable']:
                link_attrs['href'] = os.path.join(webpath, entry['name'])
            display_name = format_entry_name(entry)
            display_size = format_entry_size(entry)
            display_perm = format_entry_permission(entry)
            display_ctime = format_date(entry['stat'].st_ctime)
            display_mtime = format_date(entry['stat'].st_mtime)
            display_atime = format_date(entry['stat'].st_atime)
            table_rows.append(
                T('tr.table-row', {
                    'id': display_name,
                    'data-sort-type': entry['type'],
                    'data-sort-name': display_name,
                    'data-sort-perm': display_perm,
                    'data-sort-ctime': display_ctime,
                    'data-sort-mtime': display_mtime,
                    'data-sort-atime': display_atime,
                    'data-sort-size': entry['stat'].st_size,
                    'data-sort-order': i,
                }, [
                    T('td.table-cell-checkbox', [
                        T('input.table-row-checkbox', {
                            'type': 'checkbox',
                            'data-entry-name': entry['name']
                        })
                    ]),
                    T('td.table-cell-icon', icon_map.get(entry['type'], '')),
                    T('td.table-cell-normal', T('a.name', link_attrs, display_name)),
                    T('td.table-cell-normal', display_size),
                    T('td.table-cell-normal', display_perm),
                    T('td.table-cell-normal', display_ctime),
                    T('td.table-cell-normal', display_mtime),
                    T('td.table-cell-normal', display_atime),
                ])
            )
        if len(table_rows) == 0:
            table_rows.append(
                T('tr', [
                    T('td.table-cell-normal', {'colspan': 7}, T('i', 'empty')),
                ])
            )
        
        modification_buttons = [] if self.no_modify else [
            T('button#upload', {'type': 'button'}, 'Upload'), ' ',
            T('button#delete', {'type': 'button'}, 'Delete'),
        ]
        
        return T('html', [
            T('head', [
                T('title', webpath),
                T('meta', {'charset': 'utf-8'}),
                T('meta', {'name': 'viewport', 'content': 'width=device-width, initial-scale=1'}),
                T('style', textwrap.dedent('''
                    * {
                        font-family: monospace;
                    }
                    body,div,span,table,tr,tbody,thead,td,th {
                        padding: 0px;
                        margin: 0px;
                        border: 0px;
                    }
                    .container {
                        padding-top: 1em;
                        padding-left: 1em;
                        padding-right: 1em;
                    }
                    .section {
                        padding-bottom: 1em;
                    }
                    .table-header-link {
                        font-weight: bold;
                        // font-style: italic;
                    }
                    .table-cell-checkbox {
                        padding: 0.25em 0.25em;
                    }
                    .table-cell-normal {
                        padding: 0.25em 0.5em;
                    }
                    .table-cell-icon {
                        padding-left: 0.5em;
                    }
                    .menu-item {
                        display: inline-block;
                        margin-right: 0.5em;
                    }
                    .table-header {
                        border-bottom: 1px solid black;
                    }
                    .table {
                        border-collapse: collapse;
                        display: block;
                        white-space: nowrap;
                    }
                    .hidden {
                        display: none;
                    }
                    .mark {
                        background-color: yellow;
                    }
                    .table-header-link[data-order=desc]::after {
                        content: "-";
                    }
                    .table-header-link[data-order=asc]::after {
                        content: "+";
                    }
                '''))
            ]),
            T('body', [
                T('.container', [
                    T('.section', [
                        T('h2', '/'.join(breadcrumb_links)),
                        T('p', 'Modification is disabled.' if self.no_modify else f'Writable: {dir_writable}'),
                    ]),
                    T('.section', [
                        T('button', {'type': 'button', 'onclick': 'location.href = {}'.format(json.dumps(os.path.dirname(webpath)))}, '..'), ' ',
                        T('input.name-filter', {'type': 'text', 'placeholder': 'RegExp name filter', 'autofocus': ''}), ' ',
                        *modification_buttons,
                    ]),
                    T('.section', [
                        T('table.table', [
                            T('tr.table-header', [
                                T('td.table-cell-checkbox', T('input.table-row-checkbox-all', {'type': 'checkbox'})),
                                T('td.table-cell-normal'),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#', 'data-sort-by': 'name'}, 'name')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#', 'data-sort-by': 'size'}, 'size')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#', 'data-sort-by': 'perm'}, 'permission')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#', 'data-sort-by': 'ctime'}, 'created at')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#', 'data-sort-by': 'mtime'}, 'modified at')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#', 'data-sort-by': 'atime'}, 'accessed at')),
                            ]),
                            ''.join(table_rows),
                        ]),
                    ]),
                ]),
                T('script', textwrap.dedent(
                    f'''
                    const modifiable = {json.dumps(not self.no_modify)};
                    const writable = {json.dumps(dir_writable)};
                    '''
                )),
                T('script', textwrap.dedent(
                    '''
                    function refreshFilterResult(filterRegex) {
                        let regex;
                        try {
                            regex = new RegExp(filterRegex);
                        } catch (e) {
                            regex = new RegExp(/.*/);
                        }
                        document.querySelectorAll('.table-row').forEach(function (el) {
                            let entryName = el.getAttribute('data-sort-name');
                            if (regex.test(entryName)) {
                                el.classList.remove('hidden');
                            } else {
                                el.classList.add('hidden');
                            }
                        });
                    }
                    
                    document.querySelector('input.name-filter').addEventListener('input', function (e) {
                        e.preventDefault();
                        refreshFilterResult(e.target.value);
                    });
                    
                    function refreshButtons() {
                        let checkboxes = [...document.querySelectorAll('input.table-row-checkbox')];
                        let selected = checkboxes.filter(el => el.checked);
                        let uploadButton = document.querySelector('button#upload');
                        if (uploadButton) {
                            if (selected.length > 0 || !writable && modifiable) {
                                uploadButton.setAttribute('disabled', '');
                            } else {
                                uploadButton.removeAttribute('disabled');
                            }
                        }
                        let deleteButton = document.querySelector('button#delete');
                        if (deleteButton) {
                            if (selected.length > 0 && writable && modifiable) {
                                deleteButton.removeAttribute('disabled');
                            } else {
                                deleteButton.setAttribute('disabled', '');
                            }
                        }
                    }
                    
                    function refreshCheckboxState(changedCheckBox) {
                        let checkboxAll = document.querySelector('input.table-row-checkbox-all');
                        let checkboxes = document.querySelectorAll('input.table-row-checkbox');
                        if (changedCheckBox === checkboxAll) {
                            checkboxes.forEach(function (checkbox) {
                                checkbox.checked = checkboxAll.checked;
                            });
                        } else {
                            let allChecked = true;
                            for (let checkbox of checkboxes) {
                                if (!checkbox.checked) {
                                    allChecked = false;
                                    break;
                                }
                            }
                            checkboxAll.checked = allChecked;
                        }
                    }
                    
                    document.querySelectorAll('input.table-row-checkbox-all,input.table-row-checkbox').forEach(function (checkbox) {
                        checkbox.addEventListener('input', function (e) {
                            e.preventDefault();
                            refreshCheckboxState(e.target);
                            refreshButtons();
                        });
                    });
                    
                    function refreshTableRowOrder(criterion, sign) {
                        criterion ||= x => x.getAttribute('data-sort-order');
                        sign = Math.sign(sign || 1);
                        let table = document.querySelector('table.table');
                        let rows = [...table.querySelectorAll('.table-row')];
                        console.log(rows);
                        rows.sort((a, b) => (criterion(a) > criterion(b) ? sign : -sign));
                        for (let el of rows) {
                            el.remove();
                            table.appendChild(el);
                        }
                    }
                    
                    function createUploadForm(action = '') {
                        let form = document.createElement('form');
                        form.setAttribute('action', action);
                        form.setAttribute('method', 'post');
                        form.setAttribute('enctype', 'multipart/form-data');
                        form.style.display = 'none';
                        
                        form.appendChild(function () {
                            let action = document.createElement('input');
                            action.setAttribute('type', 'hidden');
                            action.setAttribute('name', 'action');
                            action.setAttribute('value', 'upload');
                            return action;
                        }());
                        
                        let file = document.createElement('input');
                        file.setAttribute('type', 'file');
                        file.setAttribute('name', 'file');
                        file.setAttribute('multiple', '');
                        file.addEventListener('change', function fileChangeListener(e) {
                            e.target.removeEventListener('change', fileChangeListener);
                            if (e.target.files.length > 0) {
                                document.body.appendChild(form);
                                form.submit();
                            }
                        });
                        form.appendChild(file);
                        
                        return { form, file };
                    }
                    
                    function uploadFiles(action = '') {
                        let obj = createUploadForm(action);
                        obj.file.click();
                    }
                    
                    let uploadButton = document.querySelector('button#upload');
                    if (uploadButton) {
                        uploadButton.addEventListener('click', function (e) {
                            uploadFiles();
                        });
                    }
                    
                    document.body.addEventListener('dragover', function (e) {
                        e.preventDefault();
                    });
                    
                    document.body.addEventListener('drop', function(e) {
                        console.log('test');
                        e.preventDefault();
                        if (!modifiable) {
                            alert('Modification is disabled.');
                        } else if (!writable) {
                            alert('Current directory is not writable.');
                        } else {
                            let obj = createUploadForm();
                            obj.file.files = e.dataTransfer.files;
                            obj.file.dispatchEvent(new Event('change'));
                        }
                    }, true);

                    function deleteFiles(action = '') {
                        let form = document.createElement('form');
                        form.setAttribute('action', action);
                        form.setAttribute('method', 'post');
                        form.style.display = 'none';
                        
                        form.appendChild(function () {
                            let action = document.createElement('input');
                            action.setAttribute('type', 'hidden');
                            action.setAttribute('name', 'action');
                            action.setAttribute('value', 'delete');
                            return action;
                        }());
                        
                        let selected = [...document.querySelectorAll('input.table-row-checkbox')].filter(el => el.checked);
                        
                        if (selected.length > 0) {
                            let result = confirm('Are you sure to delete these entries?');
                            if (!result) {
                                return;
                            }
                        } else if (selected.length == 0) {
                            return;
                        }
                        
                        for (let el of selected) {
                            let input = document.createElement('input');
                            input.setAttribute('type', 'hidden');
                            input.setAttribute('name', 'file');
                            input.setAttribute('value', el.getAttribute('data-entry-name'));
                            form.appendChild(input);
                        }
                     
                        document.body.appendChild(form);
                        form.submit();
                    }
                    
                    let deleteButton = document.querySelector('button#delete');
                    if (deleteButton) {
                        deleteButton.addEventListener('click', function (e) {
                            deleteFiles();
                        })
                    }
                    
                    refreshButtons();
                    
                    const sortCriteria = {
                        name: row => row.getAttribute('data-sort-name'),
                        type: row => row.getAttribute('data-sort-type'),
                        ctime: row => row.getAttribute('data-sort-ctime'),
                        mtime: row => row.getAttribute('data-sort-mtime'),
                        atime: row => row.getAttribute('data-sort-atime'),
                        size: row => row.getAttribute('data-sort-size'),
                        order: row => row.getAttribute('data-sort-order'),
                    };
                    
                    document.querySelectorAll('.table-header-link').forEach(function (link) {
                        link.addEventListener('click', function (e) {
                            e.preventDefault();

                            document.querySelectorAll('.table-header-link').forEach(function (otherLink) {
                                if (link != otherLink) {
                                    otherLink.setAttribute('data-order', '');
                                }
                            });
                            
                            let criterionKey = link.getAttribute('data-sort-by');
                            let order = link.getAttribute('data-order');
                            let criterion;
                            let sortSign;
                            
                            if (!order) {
                                order = 'asc';
                                criterion = sortCriteria[criterionKey] || sortCriteria.order;
                                sortSign = 1;
                            } else if (order === 'asc') {
                                order = 'desc';
                                criterion = sortCriteria[criterionKey] || sortCriteria.order;
                                sortSign = -1;
                            } else if (order === 'desc') {
                                order = '';
                                criterion = sortCriteria.order;
                                sortSign = 1;
                            }
                            
                            console.log(criterion);
                            
                            link.setAttribute('data-order', order);
                            refreshTableRowOrder(criterion, sortSign);
                        });
                    });
                    
                    if (location.hash === '#recent') {
                        console.log(123);
                        let a = document.querySelector('[data-sort-by=ctime]');
                        a.click();
                        a.click();
                        location.hash = '';
                    }
                    '''
                ))
            ]),
        ])
        
    def handle(self, path=''):
        if request.method == 'GET':
            return self.view(path)
        elif request.method == 'POST':
            action = request.form.get('action')
            if action == 'upload':
                return self.create(path)
            elif action == 'delete':
                return self.delete(path)
        abort(400, 'Unknown action.')
    
    def view(self, path):
        local_path = self.__get_local_path(path)
        if local_path is None:
            abort(400, 'Invalid path.')
        if not os.path.exists(local_path):
            abort(404, 'File or directory does not exist.')
        elif not get_path_readibility(local_path):
            abort(403, 'You have no permission to acces this path.')
        elif os.path.isfile(local_path):
            return send_file(local_path)
        elif os.path.isdir(local_path):
            if self.no_list:
                abort(403, 'Directory listing is forbidden.')
            return self.__list_directory(local_path)
        else:
            abort(403)
    
    def delete(self, path):
        if self.no_modify:
            abort(403, 'Modification is forbidden.')
        entry_names = request.form.getlist('file')
        local_paths = [self.__get_local_path(os.path.join(path, name)) for name in entry_names]
        for entry_name, local_path in zip(entry_names, local_paths):
            if local_path is None:
                abort(400, f'Path is invalid: {entry_name}')
            dirpath = os.path.dirname(local_path)
            if not get_path_writability(dirpath):
                abort(403, f'You have no permission to modify the parent directory of {entry_name!r}')
            if not get_path_writability(local_path):
                abort(403, f'You have no permission to delete {entry_name!r}')
        result = {}
        for entry_name, local_path in zip(entry_names, local_paths):
            entry_type = get_path_type(local_path)
            print('delete:', local_path)
            if entry_type == EntryType.FILE:
                with suppress(OSError):
                    os.remove(local_path)
            elif entry_type == EntryType.DIRECTORY:
                with suppress(OSError):
                    os.rmdir(local_path)
            result[entry_name] = not os.path.exists(local_path)
        if not all(result.values()):
            return result
        return redirect(f'/{path}', 302)

    def create(self, path):
        if self.no_modify:
            abort(403, 'Modification is forbidden.')
        local_path = self.__get_local_path(path)
        if not os.path.isdir(local_path):
            abort(403, 'Target is not a directory.')
        if 'file' not in request.files:
            abort(400, 'File is not provided.')
        for file in request.files.getlist('file'):
            filename = secure_filename(file.filename)
            filepath = os.path.join(local_path, filename)
            try:
                file.save(filepath)
            except PermissionError:
                abort(403, 'You have to permission to upload to this path')
        return redirect(f'/{path}#recent', 302)

def view_handler(path='/'):
    return path

def create_flask_app(root, basic_auth, no_list, no_modify):
    app = Flask(__name__)
    handler = Handler(root, no_list, no_modify)
    handle = handler.handle
    if basic_auth:
        auth = HTTPBasicAuth()
        auth.verify_password(lambda u, p: [None, u][f'{u}:{p}' == basic_auth])
        handle = auth.login_required(handle)
    app.add_url_rule('/', view_func=handle, methods=['GET', 'POST'])
    app.add_url_rule('/<path:path>', view_func=handle, methods=['GET', 'POST'])
    return app

def path_type(path):
    assert os.path.exists(path)
    return path

def get_display_url(scheme, host, port):
    display_urls = []
    if host == '0.0.0.0':
        display_urls.append(f'{scheme}://127.0.0.1:{port}')
        public_host = get_interface_ip(socket.AF_INET)
    elif host == '::':
        display_urls.append(f'{scheme}://[::1]:{port}')
        public_host = get_interface_ip(socket.AF_INET6)
    else:
        public_host = host

    if ':' in public_host:
        public_host = f'[{public_host}]'

    display_urls.append(f'{scheme}://{public_host}:{port}')
    return display_urls

def main():
    parser = ArgumentParser()
    parser.add_argument('--root', type=path_type, default='.')
    parser.add_argument('--host', type=str, default='0.0.0.0')
    parser.add_argument('--port', type=int, default=9999)
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--https', action='store_true')
    parser.add_argument('--basic-auth')
    parser.add_argument('--no-list', '-L', action='store_true')
    parser.add_argument('--no-modify', '-M', action='store_true')
    args = parser.parse_args()

    if args.basic_auth is not None:
        basic_auth_tuple = args.basic_auth.split(':')
        if len(basic_auth_tuple) != 2:
            raise ValueError('expect --basic-auth <username>:<password>')
        if any(len(item) == 0 for item in basic_auth_tuple):
            raise ValueError('username and password should not be empty for --basic-auth')

    print('Arguments:', vars(args))
    
    # scheme = ['http', 'https'][args.https]
    # urls = get_display_url(scheme, args.host, args.port)
    
    print('Starting Flask app...')
    create_flask_app(
        args.root,
        args.basic_auth,
        args.no_list,
        args.no_modify,
    ).run(
        host=args.host,
        port=args.port,
        debug=args.debug,
        threaded=True,
        ssl_context=('adhoc' if args.https else None),
    )

if __name__ == '__main__':
    # import ei; ei.embed(exit=True)
    main()
