unit Model.Utils;

interface

uses
  System.SysUtils;

const
  CVersion    = 1;
  CSubVersion = 0;

  //INI IDENTIFIERS
  CIdentNome = 'Nome';
  CIdentPastaDownload = 'PastaDownload';
  CIdentPastaExtrair = 'PastaExtrair';

  //DEFAULTS
  CDefaultBrowser = 'msedge.exe';
  CDefaultLink = 'http/www.exemplo.com/arquivo.rar';

var
  VFechar: Boolean;

procedure CleanVariables;
function SystemVersion: string;

implementation

procedure CleanVariables;
begin
   VFechar := False;
end;

function SystemVersion: string;
begin
   Result := ' - Versão ' + CVersion.Tostring + '.' + CSubVersion.Tostring;
end;

end.
