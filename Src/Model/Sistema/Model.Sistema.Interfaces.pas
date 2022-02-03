unit Model.Sistema.Interfaces;

interface

uses
  System.SysUtils;

type
  iModelSistema = interface
   ['{B365D427-0377-4867-8834-5C3CF5B90F62}']
   //Model.Sistema
   function OnShowName(AValue: TProc<String>): iModelSistema;
   function OnStatus(AValue: TProc<String>): iModelSistema;
   function ConfigurationLoad: iModelSistema;
   function LinksLoad: iModelSistema;
   function DownloadFiles: iModelSistema;
   function ExtractDownloadedFiles: iModelSistema;
  end;

implementation

end.
