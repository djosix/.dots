#!/usr/bin/env python3

import json
import re
import os
import socket
import textwrap
import enum
from datetime import datetime
from typing import List, NamedTuple, Optional, Union
from argparse import ArgumentParser
from contextlib import suppress

from flask import Flask, request, abort, escape, redirect
from flask.helpers import send_file
from flask_httpauth import HTTPBasicAuth
from werkzeug.serving import get_interface_ip
from werkzeug.utils import secure_filename

'''
flask
flask_httpauth
'''

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
        
    attrs = ''.join(f' {key}="{escape(value)}"' for key, value in attrs.items())
    inner = ''.join(map(str, inner))
    
    if name_tag.lower() in NO_CLOSING_TAGS:
        assert len(inner) == 0
        return f'<{name_tag}{attrs}/>'
    else:
        return f'<{name_tag}{attrs}>{inner}</{name_tag}>'

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

class Handler:
    def __init__(self, root):
        self.abs_root = os.path.abspath(root)
    
    def __get_local_path(self, path):
        abs_path = os.path.abspath(os.path.join(self.abs_root, path))
        if abs_path.startswith(self.abs_root):
            return abs_path

    def __list_directory(self, abs_dir_path):
        
        relpath = os.path.relpath(abs_dir_path, self.abs_root)
        webpath = os.path.join('/', relpath)
        webpath = os.path.abspath(webpath)
        
        entries = []
        
        for item_name in os.listdir(abs_dir_path):
            item_path = os.path.join(abs_dir_path, item_name)
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
        
        return T('html', [
            T('head', [
                T('title', 'Title'),
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
                        font-style: italic;
                    }
                    .table-cell-checkbox {
                        padding: 0.25em 0.25em;
                    }
                    .table-cell-normal {
                        padding: 0.25em 0.5em;
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
                '''))
            ]),
            T('body', [
                T('.container', [
                    T('.section', [
                        T('h2', '/'.join(breadcrumb_links)),
                    ]),
                    T('.section', [
                        T('button', {'type': 'button', 'onclick': 'location.href = {}'.format(json.dumps(os.path.dirname(webpath)))}, '..'), ' ',
                        T('input.name-filter', {'type': 'text', 'placeholder': 'RegExp name filter', 'autofocus': ''}), ' ',
                        T('button#upload', {'type': 'button'}, 'Upload'), ' ',
                        T('button#delete', {'type': 'button'}, 'Delete'),
                    ]),
                    T('.section', [
                        T('table.table', [
                            T('tr.table-header', [
                                T('td.table-cell-checkbox', T('input.table-row-checkbox-all', {'type': 'checkbox'})),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#'}, 'name')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#'}, 'size')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#'}, 'permission')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#'}, 'created at')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#'}, 'modified at')),
                                T('td.table-cell-normal', T('a.table-header-link', {'href': '#'}, 'accessed at')),
                            ]),
                            ''.join(table_rows),
                        ]),
                    ]),
                ]),
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
                        if (selected.length > 0) {
                            uploadButton.setAttribute('disabled', '');
                        } else {
                            uploadButton.removeAttribute('disabled');
                        }
                        let deleteButton = document.querySelector('button#delete');
                        if (selected.length > 0) {
                            deleteButton.removeAttribute('disabled');
                        } else {
                            deleteButton.setAttribute('disabled', '');
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
                        let rows = [...document.querySelectorAll('table.table>.table-row')];
                        rows.sort((a, b) => (criterion(a) > criterion(b) ? sign : -sign));
                        for (let el of rows) {
                            el.remove();
                            table.appendChild(el);
                        }
                    }
                    
                    function uploadFiles(action = '') {
                        
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
                        file.click();
                    }
                    
                    document.querySelector('button#upload').addEventListener('click', function (e) {
                        uploadFiles();
                    })
                    
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
                        
                        if (selected.length > 1) {
                            let result = confirm('Are you sure to delete multiple files?');
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
                    
                    document.querySelector('button#delete').addEventListener('click', function (e) {
                        deleteFiles();
                    })
                    
                    refreshButtons();
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
        abort(400, 'Unknown action')
    
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
            return self.__list_directory(local_path)
        else:
            abort(403)
    
    def delete(self, path):
        entry_names = request.form.getlist('file')
        print('delete:', entry_names)
        # return {'entry_names': entry_names}
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
        return redirect(f'/{path}', 302)

def view_handler(path='/'):
    return path

def create_flask_app(root, basic_auth, permissions):
    app = Flask(__name__)
    handler = Handler(root)
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
    parser.add_argument('--allow-list', '-l', action='store_true')
    parser.add_argument('--allow-read', '-r', action='store_true')
    parser.add_argument('--allow-create', '-c', action='store_true')
    parser.add_argument('--allow-write', '-w', action='store_true')
    parser.add_argument('--allow-delete', '-d', action='store_true')
    parser.add_argument('--allow-all', '-a', action='store_true')
    args = parser.parse_args()

    if args.basic_auth is not None:
        basic_auth_tuple = args.basic_auth.split(':')
        if len(basic_auth_tuple) != 2:
            raise ValueError('expect --basic-auth <username>:<password>')
        if any(len(item) == 0 for item in basic_auth_tuple):
            raise ValueError('username and password should not be empty for --basic-auth')

    print('Settings:')
    print(f'  root = {args.root}')
    print(f'  host = {args.host}')
    print(f'  port = {args.port}')
    print(f'  debug = {args.debug}')
    print(f'  https = {args.https}')
    print(f'  basic_auth = {args.basic_auth}')
    
    # scheme = ['http', 'https'][args.https]
    # urls = get_display_url(scheme, args.host, args.port)

    permissions = {
        'list': bool(args.allow_list or args.allow_all),
        'read': bool(args.allow_read or args.allow_all),
        'create': bool(args.allow_create or args.allow_all),
        'write': bool(args.allow_write or args.allow_all),
        'delete': bool(args.allow_delete or args.allow_all),
    }
    print('Permissions:', [key for key, value in permissions.items() if value])
    
    print('Starting Flask app...')
    create_flask_app(
        args.root,
        args.basic_auth,
        permissions,
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
