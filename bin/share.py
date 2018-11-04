#!/usr/bin/env python3
# pylint: disable=E1101

import bottle, os

@bottle.get('/')
def index():
    fmt = lambda t: '''
    <li>
        <a id="file-{i}" class="file" href="view/{x}">{x}</a>
        [<a href="#" class="delete" onclick="delFile({i})">x</a>]
    </li>
    '''.format(i=t[0], x=t[1])
    files = filter(os.path.isfile, os.listdir('./'))
    return '''
    <style>
    a.delete {
        color: black;
    }
    </style>
    <form id="uform" action="upload" method="post" enctype="multipart/form-data">
        <input type="file" name="upload" multiple>
    </form>
    <form id="dform" method="post" action="delete"></from>
    <ul>%s</ul>
    <script>
    document.querySelector("input[name=upload]").onchange = function() {
        document.getElementById("uform").submit();
    };
    var delFile = function(i) {
        let fileName = document.getElementById("file-" + i).innerText;
        if (confirm("Confirm for deleting " + fileName)) {
            let dform = document.getElementById("dform");
            let action = "delete/" + encodeURIComponent(fileName);
            dform.setAttribute("action", action);
            dform.submit();
        }
    };
    </script>
    ''' % ''.join(map(fmt, enumerate(files)))

@bottle.post('/upload')
def upload():
    for u in bottle.request.files.getall('upload'):
        with open(u.raw_filename, 'wb') as f:
            f.write(u.file.read())
    return bottle.redirect('/')

@bottle.post('/delete/<filename>')
def delete(filename):
    os.remove(filename)
    return bottle.redirect('/')

@bottle.get('/view/<filename>')
def view(filename):
    return bottle.static_file(filename, './')

host = os.environ.get('HOST', '0.0.0.0')
port = os.environ.get('PORT', 9999)
server = os.environ.get('SERVER', 'wsgiref')

bottle.run(host=host, port=port, server=server)
