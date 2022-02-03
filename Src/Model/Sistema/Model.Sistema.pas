unit Model.Sistema;

interface

uses
  System.SysUtils,
  System.IniFiles,
  Model.Sistema.Interfaces,
  MyLibrary,
  MyIniLibrary,
  MyTxtLibrary;

type
  TModelSistema = class(TInterfacedObject, iModelSistema)
  private
    FIniFile: iMyIniLibrary;
    FLinksFile: iMyTxtLibrary;
    FNome: string;
    FPastaDownload: string;
    FPastaExtrair: string;

    procedure CreateConfFile;
  protected
    function ConfigurationLoad: iModelSistema;
    function LinksLoad: iModelSistema;
  public
    constructor Create;
    class function New: iModelSistema;
  end;

implementation

{ TModelSistema }

uses
  Model.Utils;

class function TModelSistema.New: iModelSistema;
begin
   Result := Self.Create;
end;

constructor TModelSistema.Create;
begin
   Model.Utils.CleanVariables;
   FIniFile   := TMyIniLibrary.New;
   FLinksFile := TMyTxtLibrary.New;
end;

function TModelSistema.ConfigurationLoad: iModelSistema;
begin
   Result := Self;

   if(Model.Utils.VFechar)then
     Exit;
end;

procedure TModelSistema.CreateConfFile;
begin

end;

function TModelSistema.LinksLoad: iModelSistema;
begin
   Result := Self;

   if(Model.Utils.VFechar)then
     Exit;
end;

end.
