# -*- coding: latin1 -*-

RCS_ID = '$Id: miscfete.py,v 1.1 2004/10/11 22:35:14 setepo Exp $'

class ProgressData:

    def __init__(self, prompt, out = None):
        import cStringIO, time

        self.total = 0
        self.last_time = time.time()
        self.last_size = 0
        self.prompt = prompt
        self.data = cStringIO.StringIO()

        if out is None:
            import sys
            self.out = sys.stderr
        else:
            self.out = out

    def add(self, data):
        import time

        self.data.write(data)
        self.total += len(data)

        diff = time.time() - self.last_time

        if diff > 1:
            inc = (self.total - self.last_size) / 1024
            self.out.write('\r%s %d bytes (%.2f K/s)\033[K' % 
                            (self.prompt,
                             self.total, 
                             inc / diff))
            self.out.flush()
            self.last_time = time.time()
            self.last_size = self.total

    def end(self):
        self.out.write('\r\033[K')
        self.out.flush()

    def get(self):
        return self.data.getvalue()

def read_response(fp):

    pd = ProgressData('Leidos')
    while True:
        new = fp.read(1024)
        if not new:
            break

        pd.add(new)

    pd.end()
    return pd.get()

class DownloadError(Exception):
    pass

class Download:

    def __init__(self, usuario=None, clave=None, interactivo = True, maxintentos = 10):
        self.usuario = usuario
        self.clave = clave
        self.interactivo = interactivo
        self.maxintentos = maxintentos

    def open(self, req):
        import urllib2

        #print 'DEBUG: Abriendo', url

        if isinstance(req, str):
            req = urllib2.Request(req)

        intento = 0
        handle = None
        while handle is None:
            intento += 1
            try:
                handle = urllib2.urlopen(req)
            except urllib2.URLError, e:
                if intento > self.maxintentos:
                    raise DownloadError, ('Máximo número de intentos excedido', None)

                if not hasattr(e, 'code'):
                    raise DownloadError, ('No se pudo conectar al servidor', e)

                if e.code == 401:
                    if intento > 1:
                        self.usuario = self.clave = None
                        print ' - Intento #%d' % intento

                    if not (self.interactivo or (self.usuario and self.clave)):
                        raise DownloadError, ('No se puede autentificar en la web', None)

                    if not self.usuario:
                        self.usuario = raw_input('Usuario: ')
                    if not self.clave:
                        import getpass
                        self.clave = getpass.getpass('Clave para %s: ' % self.usuario)

                    from base64 import encodestring as es
                    req.add_header("Authorization",  "Basic " + es('%s:%s' % (self.usuario, self.clave)).strip())
                else:
                    raise DownloadError, ('No se pudo descargar la url', e)

        return handle


class ConfigError(Exception):
    pass

class BasicConfig(object):
    # Prescindimos del módulo ConfigParser por ahora, ya que éste 
    # trabaja sólo con diccionaciorios

    def __init__(self, fileobj = None, ischild = False):

        self._values = {}
        self._ischild = ischild

        if fileobj is None:
            return

        import re
        syntax = [
             (re.compile(r'\s*[;#].*'), lambda: None),
             (re.compile(r'\s*'), lambda: None),
             (re.compile(r'\s*\[\s*(\w+)\s*\]\s*'), self._add_section),
             (re.compile(r'\s*(\w+)\s*=\s*(.*)\s*'), self._add_value)
        ]

        self._numline = 0
        self._cursect = None

        for line in fileobj.xreadlines():
            self._numline += 1
            line = line.strip()
            valid = False

            for regex, fn in syntax:
                m = regex.match(line)
                if m:
                    fn(*m.groups())
                    valid = True

            if not valid:
                raise ConfigError, ('Línea no reconocida', self._numline)

        del self._numline
        del self._cursect

    def _add_section(self, section):
        self._cursect = BasicConfig(ischild = True)
        self._values[section] = self._cursect
        return self._cursect

    def _add_value(self, key, value):
        if self._cursect is None:
            raise ConfigError, ('No se puede establecer un valor antes de abrir una sección', self._numline)

        self._cursect._values[key] = value

    def __getattr__(self, key):
        try:
            return self._values[key]
        except KeyError:
            if self._ischild:
                return ''
            else:
                return BasicConfig(ischild = True)

