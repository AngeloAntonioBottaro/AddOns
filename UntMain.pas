unit UntMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.ImageList, Vcl.ImgList;

type
  TFrmMain = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    lbNome: TLabel;
    OpenDialog: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    VTotItens: Integer;

    procedure AddStatus(pStr: string);
    procedure ExisteArqConf;
    procedure ExisteArqLinks;
    procedure CriarArqConf;
    procedure LimparPastaDownload;
    procedure BaixarArquivos;
    procedure ListaArqBaixados;
    procedure CloseBrowser;
    procedure OpenGameExe;
    procedure ExtrairArquivos;
    function AppJaRodando: Boolean;
    function ConfigRealizadas: Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses UntBibliotecaFuncoes;

procedure TFrmMain.AddStatus(pStr: string);
begin
   StatusBar1.Panels[0].Text := pStr;
   Application.ProcessMessages;
end;

function TFrmMain.AppJaRodando: Boolean;
begin
   if(ReadIniFileStr('APP') = 'SIM')then
   begin
      AddStatus('Executável já esta aberto');
      Sleep(3000);
      Result := True;
   end
   else
   begin
      //REGISTRA QUE ABRIU UM
      WriteIniFile('APP', 'SIM');
      Result := False;
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.BaixarArquivos;
var
  vArq: TextFile;
  vLink: string;
begin
   AddStatus('Baixando arquivos');
   VTotItens := 0;
   Application.ProcessMessages;

   AssignFile(vArq, GetAppPath() + GetAppName() + '.txt');
   Reset(vArq);

   while Eof(vArq) = False do
   begin
      Readln(vArq, vLink);
      if(Trim(vLink) <> '')and(Trim(vLink) <> '404')then
      begin
         OpenLink(vLink, tpAbrirLinkInvisivel);
         Application.ProcessMessages;
         Sleep(15000);
         IncInt(vTotItens);
         Application.ProcessMessages;
      end;
   end;
   CloseFile(vArq);
   Sleep(5000);
   Application.ProcessMessages;
end;

procedure TFrmMain.CloseBrowser;
var
  vBrowser: string;
begin
   vBrowser := ReadIniFileStr('BROWSER');

   if(vBrowser <> '')then
   begin
      CloseEXE(vBrowser);
      Sleep(5000);
   end;
   Application.ProcessMessages;
end;

function TFrmMain.ConfigRealizadas: Boolean;
begin
   Result := True;
   if(ReadIniFileStr('NOME') = 'Configurar')then
   begin
      AddStatus('Configuração necessária');
      WriteIniFile('APP', 'NAO');
      Result := False;
      Sleep(3000);
   end;

   lbNome.Caption := ReadIniFileStr('NOME');
   Application.ProcessMessages;
end;

procedure TFrmMain.CriarArqConf;
var
  vCaminhoExecutavel: TFileName;
begin
   WriteIniFile('NOME', 'Configurar');
   WriteIniFile('PASTADOWNLOAD', SelectDir('Selecione a pasta dos downloads'));
   WriteIniFile('PASTAEXTRAIR', SelectDir('Selecione a pasta onde os arquivos serão extraidos'));
   WriteIniFile('BROWSER','msedge.exe');
   WriteIniFile('APP', 'NAO');

   OpenDialog.Title := 'Selecine o executavel que será aberto';
   if(OpenDialog.Execute())then
   begin
      vCaminhoExecutavel := OpenDialog.FileName;
      WriteIniFile('EXECUTAVEL', vCaminhoExecutavel);
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
   Timer1.Enabled := True;
end;

procedure TFrmMain.LimparPastaDownload;
var
  vnomeArq: string;
  I: Integer;
  vPastaDownload: string;
begin
   AddStatus('Limpando pasta de downloads');
   vPastaDownload := ReadIniFileStr('PASTADOWNLOAD');

   ListFiles(Memo1, vPastaDownload);
   for I := 0 to Memo1.Lines.Count do
   begin
      vnomeArq := ExtractFileName(Memo1.Lines[i]);

      //DELETA OS ARQUIVOS
      DeleteFile(vPastaDownload + vnomeArq);
      Application.ProcessMessages;
   end;
end;

procedure TFrmMain.ListaArqBaixados;
var
  vPastaDownload: string;
begin
   AddStatus('Verificando arquivos baixados');
   Application.ProcessMessages;

   Memo1.Lines.Clear;
   vPastaDownload := ReadIniFileStr('PASTADOWNLOAD');

   repeat
     ListFiles(Memo1, vPastaDownload, 'zip');
     Sleep(2000);
   until (vTotItens = Memo1.Lines.Count);

   AddStatus('Arquivos baixados com sucesso');
end;

procedure TFrmMain.OpenGameExe;
var
  vCaminhoExecutavel: string;
begin
   vCaminhoExecutavel := Trim(ReadIniFileStr('EXECUTAVEL'));

   if(vCaminhoExecutavel <> '')then
   begin
      OpenLink(vCaminhoExecutavel);
      Application.ProcessMessages;
      Sleep(2000);
   end;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
begin
   try
     Timer1.Enabled := False;

     //VERIFICA SE EXISTE O ARQUIVO DE CONFIGURACAO
     Self.ExisteArqConf;

     //FECHA O EXE CASO JA TIVER UM ABERTO
     if(Self.AppJaRodando)then
     begin
        FrmMain.Close;
        Exit;
     end;

     //VERIFICA SE EXISTE O ARQUIVO COM OS LINKS
     Self.ExisteArqLinks;

     //VERIFICA SE FOI REALIZADO AS CONFIGURACOES
     if not(Self.ConfigRealizadas)then
     begin
        FrmMain.Close;
        Exit;
     end;

     //LIMPA A PASTA DOWNLOAD
     Self.LimparPastaDownload;

     //VERIFICA SE ESTA CONECTADO COM A INTERNET PARA PODER BAIXAR OS ARQUIVOS
     AddStatus('Verificando conexão da internet');
     if(InternetConnection = False)then
     begin
        Timer1.Interval := 30000;
        AddStatus('Sem conexão com a internet');
        Timer1.Enabled := True;
        Exit;
     end;

     //PERCORRE OS LINKS BAIXANDO TODOS
     Self.BaixarArquivos;

     //LISTA OS ARQUIVOS BAIXADOS
     Self.ListaArqBaixados;

     //FECHA O BROWSER
     Self.CloseBrowser;

     //EXTRAI OS ARQUIVOS PARA A PASTA SELECIONADA
     Self.ExtrairArquivos;

     //ABRE O EXE DESEJADO
     Self.OpenGameExe;
   finally
     WriteIniFile('APP', 'NAO');
     Application.ProcessMessages;
     FrmMain.Close;
   end;
end;

procedure TFrmMain.ExisteArqConf;
begin
   AddStatus('Verificando arquivo de configuração');
   if not(FileExists(GetAppPath() + GetAppName() + '.ini'))then
   begin
      CriarArqConf;
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.ExisteArqLinks;
var
  vArq: TextFile;
begin
   AddStatus('Verificando arquivo com os links');
   AssignFile(vArq, GetAppPath() + GetAppName() + '.txt');

   if not(FileExists(GetAppPath() + GetAppName() + '.txt'))then
   begin
      Rewrite(vArq);
      Writeln(vArq,'404');
      CloseFile(vArq);
   end;
   Reset(vArq);
   CloseFile(vArq);

   Application.ProcessMessages;
end;

procedure TFrmMain.ExtrairArquivos;
var
  I: Integer;
  vPastaExtrair: string;
  vPastaDownload: string;
  vnomeArq: string;
begin
   vPastaDownload := ReadIniFileStr('PASTADOWNLOAD');
   vPastaExtrair  := ReadIniFileStr('PASTAEXTRAIR');

   AddStatus('Extraindo arquivos para: ' + vPastaExtrair);
   Application.ProcessMessages;

   for I := 0 to Memo1.Lines.Count do
   begin
      vnomeArq := ExtractFileName(Memo1.Lines[i]);

      //DESCOMPACTA NA PASTA CERTA E EXCLUI O ARQUIVO DOS DOWNLOADS
      if(DescompactFile(vPastaDownload + vnomeArq, vPastaExtrair))then
      begin
         DeleteFile(vPastaDownload + vnomeArq);
      end;
      Application.ProcessMessages;
   end;

   AddStatus('Concluido');
   Sleep(5000);
   Application.ProcessMessages;
end;

end.
