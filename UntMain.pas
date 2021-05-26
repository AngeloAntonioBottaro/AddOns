unit UntMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.ImageList, Vcl.ImgList;

const
   CVersao:    string = '01';
   CSubVersao: string = '00';

type
  TFrmMain = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    lbNome: TLabel;
    OpenDialog: TOpenDialog;
    BtnFechar: TImage;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    VTotItens: Integer;
    VPastaDownload, VPastaExtrair, VCaminhoExecutavel, VBrowser: String;
    VInternet, VFechar: Boolean;

    procedure AddStatus(pStr: string);
    procedure ExisteArqConf;
    procedure ExisteArqLinks;
    procedure CriarArqConf;
    procedure LimparPastaDownload;
    procedure BaixarArquivos;
    procedure VerificarArqBaixados;
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
   if(VFechar = False)then StatusBar1.Panels[0].Text := pStr;
   Application.ProcessMessages;
end;

function TFrmMain.AppJaRodando: Boolean;
begin
   if(UpperCase(ReadIniFileStr('APP')) = UpperCase('SIM'))then
   begin
      AddStatus('Execut�vel j� est� aberto');
      Sleep(3000);
      Result := True;
   end
   else
   begin
      //REGISTRA QUE ABRIU
      WriteIniFile('APP', UpperCase('SIM'));
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
   while(Eof(vArq) = False)and(VFechar = False)do
   begin
      Readln(vArq, vLink);
      if(Trim(vLink) <> '')and(Trim(vLink) <> '404')then
      begin
         OpenLink(vLink, tpAbrirLinkInvisivel);
         Application.ProcessMessages;
         IncInt(vTotItens);

         //CONTINUA APENAS QUANDO TIVER BAIXADO
         Self.ListaArqBaixados;

         Application.ProcessMessages;
      end;
   end;
   CloseFile(vArq);
   Sleep(5000);
   Application.ProcessMessages;
end;

procedure TFrmMain.BtnFecharClick(Sender: TObject);
begin
   AddStatus('Processo cancelado!');
   VFechar := True;
end;

procedure TFrmMain.CloseBrowser;
begin
   if(VBrowser <> '')then
   begin
      CloseEXE(VBrowser);
      Sleep(5000);
   end;
   Application.ProcessMessages;
end;

function TFrmMain.ConfigRealizadas: Boolean;
begin
   if(Trim(ReadIniFileStr('NOME')) = 'Configurar')then
   begin
      AddStatus('Configura��o necess�ria');
      WriteIniFile('APP', 'NAO');
      Result := False;
      Sleep(3000);
   end
   else
   begin
      lbNome.Caption     := Trim(ReadIniFileStr('NOME'));
      VPastaDownload     := Trim(ReadIniFileStr('PASTADOWNLOAD'));
      VPastaExtrair      := Trim(ReadIniFileStr('PASTAEXTRAIR'));
      VCaminhoExecutavel := Trim(ReadIniFileStr('EXECUTAVEL'));
      VBrowser           := Trim(ReadIniFileStr('BROWSER'));
      Result := True;
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.CriarArqConf;
begin
   WriteIniFile('NOME', 'Configurar');
   WriteIniFile('PASTADOWNLOAD', SelectDir('Selecione a pasta dos downloads'));
   WriteIniFile('PASTAEXTRAIR', SelectDir('Selecione a pasta onde os arquivos ser�o extraidos'));
   WriteIniFile('BROWSER','msedge.exe');
   WriteIniFile('APP', 'NAO');

   OpenDialog.Title := 'Selecine o executavel que ser� aberto';
   if(OpenDialog.Execute())then
   begin
      VCaminhoExecutavel := OpenDialog.FileName;
      WriteIniFile('EXECUTAVEL', VCaminhoExecutavel);
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   Self.Caption := Self.Caption + '  - Vers�o: ' + CVersao + '.' + CSubVersao;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
   VInternet      := True;
   VFechar        := False;
   Timer1.Enabled := True;
end;

procedure TFrmMain.LimparPastaDownload;
var
  vnomeArq: string;
  I: Integer;
begin
   AddStatus('Limpando pasta de downloads');

   ListFiles(Memo1, VPastaDownload);
   for I := 0 to Memo1.Lines.Count do
   begin
      vnomeArq := ExtractFileName(Memo1.Lines[i]);

      //DELETA OS ARQUIVOS
      DeleteFile(VPastaDownload + vnomeArq);
      Application.ProcessMessages;
   end;
end;

procedure TFrmMain.ListaArqBaixados;
begin
   repeat
     ListFiles(Memo1, VPastaDownload, 'zip');
     Sleep(1000);
   until (VTotItens = Memo1.Lines.Count)or(VFechar = True);
   Application.ProcessMessages;
end;

procedure TFrmMain.OpenGameExe;
begin
   if(VCaminhoExecutavel <> '')and(VFechar = False)then
   begin
      OpenLink(VCaminhoExecutavel);
      Application.ProcessMessages;
      Sleep(2000);
   end;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
begin
   try
     Timer1.Enabled := False;

     //VERIFICA SE EXISTE O ARQUIVO DE CONFIGURACAO
     if(VFechar = False)then Self.ExisteArqConf;

     //VERIFICA SE EXISTE O ARQUIVO COM OS LINKS
     if(VFechar = False)then Self.ExisteArqLinks;

     //FECHA O EXE CASO JA TIVER UM ABERTO
     if(VInternet)and(Self.AppJaRodando)then
     begin
        FrmMain.Close;
        Exit;
     end;

     //VERIFICA SE FOI REALIZADO AS CONFIGURACOES
     if not(Self.ConfigRealizadas)then
     begin
        FrmMain.Close;
        Exit;
     end;

     //LIMPA A PASTA DOWNLOAD
     Self.LimparPastaDownload;

     //VERIFICA SE ESTA CONECTADO COM A INTERNET PARA PODER BAIXAR OS ARQUIVOS
     AddStatus('Verificando conex�o da internet');
     VInternet := InternetConnection();
     if(VInternet = False)then
     begin
        Timer1.Interval := 5000;
        AddStatus('Sem conex�o com a internet');
        Timer1.Enabled := True;
        Exit;
     end;

     //PERCORRE OS LINKS BAIXANDO TODOS
     if(VFechar = False)then Self.BaixarArquivos;

     //LISTA OS ARQUIVOS BAIXADOS
     if(VFechar = False)then Self.VerificarArqBaixados;

     //FECHA O BROWSER
     Self.CloseBrowser;

     //EXTRAI OS ARQUIVOS PARA A PASTA SELECIONADA
     if(VFechar = False)then Self.ExtrairArquivos;

     //LIMPA A PASTA DOWNLOAD
     Self.LimparPastaDownload;

     AddStatus('Processo conclu�do!');
     Application.ProcessMessages;
     Sleep(5000);

     //ABRE O EXE DESEJADO
     if(VFechar = False)then Self.OpenGameExe;
   finally
   begin
      if(VInternet)or(VFechar)then
      begin
         WriteIniFile('APP', 'NAO');
         Application.ProcessMessages;
         FrmMain.Close;
      end;
   end;
   end;
end;

procedure TFrmMain.VerificarArqBaixados;
begin
   AddStatus('Verificando arquivos baixados');
   Application.ProcessMessages;

   Self.ListaArqBaixados;

   AddStatus('Arquivos baixados com sucesso');
   Application.ProcessMessages;
end;

procedure TFrmMain.ExisteArqConf;
begin
   AddStatus('Verificando arquivo de configura��o');
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
  vnomeArq: string;
begin
   AddStatus('Extraindo arquivos para: ' + VPastaExtrair);
   Application.ProcessMessages;

   for I := 0 to Memo1.Lines.Count do
   begin
      if(VFechar)then Break;

      vnomeArq := ExtractFileName(Memo1.Lines[i]);

      //DESCOMPACTA NA PASTA CERTA E EXCLUI O ARQUIVO DOS DOWNLOADS
      if(DescompactFile(VPastaDownload + vnomeArq, VPastaExtrair))then
      begin
         DeleteFile(VPastaDownload + vnomeArq);
      end;
      Application.ProcessMessages;
   end;

   AddStatus('Arquivos descompactados');
   Sleep(2000);
   Application.ProcessMessages;
end;

end.
