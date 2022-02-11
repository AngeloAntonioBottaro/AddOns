unit Model.Sistema;

interface

uses
  System.SysUtils,
  System.IniFiles,
  System.Classes,
  Model.Sistema.Interfaces,
  MyLibrary,
  MyIniLibrary,
  MyTxtLibrary;

type
  TModelSistema = class(TInterfacedObject, iModelSistema)
  private
    FOnShowName: TProc<String>;
    FOnStatus: TProc<String>;

    FEncerrar: Boolean;

    FIniFile: iMyIniLibrary;
    FLinksFile: iMyTxtLibrary;
    FNome: string;
    FPastaDownload: string;
    FPastaExtrair: string;
    FBrowser: string;

    FLinksCounter: Integer;

    procedure DoShowName(AMsg: string);
    procedure DoStatus(AMsg: string);

    function Encerrar: Boolean;

    function Nome: string;
    function PastaDownload: string;
    function PastaExtrair: string;
    function Browser: string;

    procedure CreateConfFile;
    procedure CreateLinksfFile;
    procedure VerifyInternet;
    procedure ClearDownloadRepository;
    procedure ProcessFilesDownlod;
    procedure WaitDownloadFinish;
  protected
    function OnShowName(AValue: TProc<String>): iModelSistema;
    function OnStatus(AValue: TProc<String>): iModelSistema;

    function VerifyApplicationOpen: iModelSistema;
    function ConfigurationLoad: iModelSistema;
    function LinksLoad: iModelSistema;
    function DownloadFiles: iModelSistema;
    function ExtractDownloadedFiles: iModelSistema;
    function CloseBrowser: iModelSistema;
    function CloseSystem: iModelSistema;
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
   FIniFile      := TMyIniLibrary.New;
   FLinksFile    := TMyTxtLibrary.New;
   FEncerrar     := False;
   FLinksCounter := 0;
end;

function TModelSistema.OnShowName(AValue: TProc<String>): iModelSistema;
begin
   Result      := Self;
   FOnShowName := AValue;
end;

procedure TModelSistema.DoShowName(AMsg: string);
begin
   if(Assigned(FOnShowName))then
     FOnShowName(AMsg);
end;

function TModelSistema.OnStatus(AValue: TProc<String>): iModelSistema;
begin
   Result    := Self;
   FOnStatus := AValue;
end;

procedure TModelSistema.DoStatus(AMsg: string);
begin
   if(Assigned(FOnStatus))then
     FOnStatus(AMsg);
end;

function TModelSistema.Nome: string;
begin
   if(FNome = EmptyStr)then
     FNome := Model.Utils.CDefaultNome;

   Result := FNome;
end;

function TModelSistema.PastaDownload: string;
begin
   if(FPastaDownload = EmptyStr)then
     FPastaDownload := MyLibrary.SelectDir('Selecione a pasta onde os arquivos baixados estão');

   Result := IncludeTrailingPathDelimiter(FPastaDownload);
end;

function TModelSistema.PastaExtrair: string;
begin
   if(FPastaExtrair = EmptyStr)then
     FPastaExtrair := MyLibrary.SelectDir('Selecione a pasta para qual os arquivos serão extraidos');

   Result := IncludeTrailingPathDelimiter(FPastaExtrair);
end;

function TModelSistema.Browser: string;
begin
   if(FBrowser = EmptyStr)then
     FBrowser := Model.Utils.CDefaultBrowser;
   Result := FBrowser;
end;

function TModelSistema.Encerrar: Boolean;
begin
   Result := Model.Utils.VFechar or FEncerrar;
end;

function TModelSistema.VerifyApplicationOpen: iModelSistema;
begin
   Result      := Self;
   VAppRunning := MyLibrary.ThisAppRunning;

   if(not VAppRunning)then
     Exit;

   Self.DoShowName('Aplicativo já iniciado');
   Self.CloseSystem;
end;

function TModelSistema.ConfigurationLoad: iModelSistema;
begin
   Result := Self;

   if(Self.Encerrar)then
     Exit;

   Self.DoStatus('Carregando configurações');

   if(not FileExists(FIniFile.Path + FIniFile.Name))then
   begin
      Self.CreateConfFile;
      Model.Utils.VFechar := True;
      Exit;
   end;

   FNome          := FIniFile.Identifier(Model.Utils.CIdentNome).ReadIniFileStr;
   FPastaDownload := FIniFile.Identifier(Model.Utils.CIdentPastaDownload).ReadIniFileStr;
   FPastaExtrair  := FIniFile.Identifier(Model.Utils.CIdentPastaExtrair).ReadIniFileStr;
   FBrowser       := FIniFile.Identifier(Model.Utils.CIdentBrowser).ReadIniFileStr;

   DoShowName(Self.Nome);
end;

procedure TModelSistema.CreateConfFile;
begin
   Self.DoStatus('Criando arquivo de configurações');

   FIniFile
    .Identifier(Model.Utils.CIdentNome).WriteIniFile(Self.Nome)
    .Identifier(Model.Utils.CIdentPastaDownload).WriteIniFile(Self.PastaDownload)
    .Identifier(Model.Utils.CIdentPastaExtrair).WriteIniFile(Self.PastaExtrair)
    .Identifier(Model.Utils.CIdentBrowser).WriteIniFile(Model.Utils.CDefaultBrowser);
end;

function TModelSistema.LinksLoad: iModelSistema;
begin
   Result := Self;

   if(Self.Encerrar)then
     Exit;

   Self.DoStatus('Carregando links para download');

   if(not FileExists(FLinksFile.Caminho + FLinksFile.Nome))then
   begin
      Self.CreateLinksfFile;
      Model.Utils.VFechar := True;
      Exit;
   end;
end;

procedure TModelSistema.CreateLinksfFile;
begin
   Self.DoStatus('Criando arquivo dos links para preenchimento');

   FLinksFile
    .WriteTxtFile(CDefaultLink);
end;

function TModelSistema.DownloadFiles: iModelSistema;
begin
   Result := Self;

   Self.VerifyInternet;
   Self.ClearDownloadRepository;
   Self.ProcessFilesDownlod;
end;

procedure TModelSistema.VerifyInternet;
begin
   if(Self.Encerrar)then
     Exit;

   Self.DoStatus('Verificando status da internet');

   if(not MyLibrary.InternetConnection)then
   begin
      Self.DoStatus('Sem conexão com a internet');
      FEncerrar := True;
      Exit;
   end;

   Self.DoStatus('Conexão com a internet');
end;

procedure TModelSistema.ClearDownloadRepository;
var
  LListaArquivos: TStrings;
  I: Integer;
begin
   if(Self.Encerrar)then
     Exit;

   Self.DoStatus('Limpando a pasta de downloads');

   LListaArquivos := TStringList.Create;
   try
     MyLibrary.ListFiles(LListaArquivos, Self.PastaDownload);

     for I := 0 to LListaArquivos.Count - 1 do
     begin
        DeleteFile(Self.PastaDownload + LListaArquivos[I]);
     end;
   finally
     LListaArquivos.DisposeOf;
   end;

   Self.DoStatus('Pasta de downloads limpa');
end;

procedure TModelSistema.ProcessFilesDownlod;
var
  LListaLinks: TStrings;
  I: Integer;
begin
   if(Self.Encerrar)then
     Exit;

   Self.DoStatus('Fazendo download dos arquivos');

   LListaLinks := TStringList.Create;
   try
     FLinksFile.ReadTxtFile(LListaLinks);

     for I := 0 to LListaLinks.Count - 1 do
     begin
        if(Self.Encerrar)then
          Exit;

        if(LListaLinks[I].Trim = Model.Utils.CDefaultLink)then
        begin
           Self.DoStatus('Verifique os links informados no arquivo de links');
           Sleep(2000);
           Model.Utils.VFechar := True;
           Break;
        end;

        FLinksCounter := I + 1;
        MyLibrary.OpenLink(LListaLinks[I].Trim, tpAbrirLinkMinimizado);
        Self.WaitDownloadFinish;
     end;

     Self.DoStatus('Realizado download dos arquivos');
   finally
     LListaLinks.DisposeOf;
   end;
end;

procedure TModelSistema.WaitDownloadFinish;
var
  LListaArquivos: TStrings;
begin
   if(Self.Encerrar)then
     Exit;

   LListaArquivos := TStringList.Create;
   try
     repeat
       Self.DoStatus('');
       MyLibrary.ListFiles(LListaArquivos, Self.PastaDownload, 'zip');
     until(FLinksCounter = LListaArquivos.Count);
   finally
     LListaArquivos.DisposeOf;
   end;
end;

function TModelSistema.ExtractDownloadedFiles: iModelSistema;
var
  LListaArquivos: TStrings;
  I: Integer;
  LFile: string;
begin
   Result := Self;

   if(Self.Encerrar)then
     Exit;

   Self.DoStatus('Extraindo arquivos baixados para pasta: ' + Self.PastaExtrair);

   LListaArquivos := TStringList.Create;
   try
     MyLibrary.ListFiles(LListaArquivos, Self.PastaDownload);

     for I := 0 to LListaArquivos.Count - 1 do
     begin
        LFile := Self.PastaDownload + LListaArquivos[I];
        MyLibrary.DescompactFile(LFile, Self.PastaExtrair);
     end;
   finally
     LListaArquivos.DisposeOf;
   end;

   Self.DoStatus('Arquivos extraidos com sucesso');

   Self.ClearDownloadRepository;
end;

function TModelSistema.CloseBrowser: iModelSistema;
begin
   Result := Self;

   if(VAppRunning)then
     Exit;

   Self.DoStatus('Fechando o navegador');
   MyLibrary.CloseEXE(Self.Browser);
end;

function TModelSistema.CloseSystem: iModelSistema;
begin
   Result := Self;
   Self.DoStatus('Finalizando sistema...');
   Model.Utils.VFechar := True;
   Sleep(2000);
end;

end.
