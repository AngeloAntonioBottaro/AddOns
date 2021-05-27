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
    mmLinks: TMemo;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    VTotItens: Integer;
    VPastaDownload, VPastaExtrair, VCaminhoExecutavel, VBrowser: String;
    VInternet, VFechar: Boolean;

    procedure BehaviorException( Sender : TObject; E: Exception);
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
    procedure AppJaRodando;
    procedure ConfigRealizadas;
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

procedure TFrmMain.AppJaRodando;
begin
   if(UpperCase(ReadIniFileStr('APP')) = UpperCase('SIM'))then
   begin
      raise Exception.Create('Executável já está aberto');
   end
   else
   begin
      //REGISTRA QUE ABRIU
      WriteIniFile('APP', UpperCase('SIM'));
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.BaixarArquivos;
var
  I: Integer;
begin
   AddStatus('Baixando arquivos');
   VTotItens := 0;
   Application.ProcessMessages;

   ReadTxtFile(mmLinks.Lines);

   if(Trim(mmLinks.Lines.Text) = '404')then
      raise Exception.Create('Arquivo sem os links configurados');

   for I := 0 to mmLinks.Lines.Count - 1 do
   begin
      if(VFechar)then Exit;

      if not(mmLinks.Lines[I].IsEmpty)then
      begin
         OpenLink(mmLinks.Lines[I], tpAbrirLinkInvisivel);
         Application.ProcessMessages;
         IncInt(vTotItens);

         //CONTINUA APENAS QUANDO TIVER BAIXADO
         Self.ListaArqBaixados;

         Application.ProcessMessages;
      end;
   end;
   Sleep(5000);
   Application.ProcessMessages;
end;

procedure TFrmMain.BehaviorException(Sender: TObject; E: Exception);
begin
   AddStatus(E.Message);
   Sleep(3000);
   BtnFecharClick(Sender);
end;

procedure TFrmMain.BtnFecharClick(Sender: TObject);
begin
   AddStatus('Processo cancelado!');
   VFechar := True;
end;

procedure TFrmMain.CloseBrowser;
begin
   CloseEXE(VBrowser);
   Sleep(5000);
   Application.ProcessMessages;
end;

procedure TFrmMain.ConfigRealizadas;
begin
   if(Trim(ReadIniFileStr('NOME')) = 'Configurar')then
   begin
      WriteIniFile('APP', 'NAO');
      raise Exception.Create('Configuração necessária');
      Sleep(3000);
   end
   else
   begin
      lbNome.Caption     := Trim(ReadIniFileStr('NOME'));
      VPastaDownload     := Trim(ReadIniFileStr('PASTADOWNLOAD'));
      VPastaExtrair      := Trim(ReadIniFileStr('PASTAEXTRAIR'));
      VCaminhoExecutavel := Trim(ReadIniFileStr('EXECUTAVEL'));
      VBrowser           := Trim(ReadIniFileStr('BROWSER'));
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.CriarArqConf;
begin
   WriteIniFile('NOME', 'Configurar');
   WriteIniFile('PASTADOWNLOAD', SelectDir('Selecione a pasta dos downloads'));
   WriteIniFile('PASTAEXTRAIR', SelectDir('Selecione a pasta onde os arquivos serão extraidos'));
   WriteIniFile('BROWSER','msedge.exe');
   WriteIniFile('APP', 'NAO');

   OpenDialog.Title := 'Selecine o executavel que será aberto';
   if(OpenDialog.Execute())then
   begin
      VCaminhoExecutavel := OpenDialog.FileName;
      WriteIniFile('EXECUTAVEL', VCaminhoExecutavel);
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   ReportMemoryLeaksOnShutdown := True;
   Application.OnException := BehaviorException;
   Self.Caption := Self.Caption + '  - Versão: ' + CVersao + '.' + CSubVersao;
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

   ListFiles(Memo1.Lines, VPastaDownload);
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
     ListFiles(Memo1.Lines, VPastaDownload, 'zip');
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
     if(VInternet)and(VFechar = False)then Self.AppJaRodando;

     //VERIFICA SE FOI REALIZADO AS CONFIGURACOES
     if(VFechar = False)then Self.ConfigRealizadas;

     //LIMPA A PASTA DOWNLOAD
     Self.LimparPastaDownload;

     //VERIFICA SE ESTA CONECTADO COM A INTERNET PARA PODER BAIXAR OS ARQUIVOS
     AddStatus('Verificando conexão da internet');
     VInternet := InternetConnection();
     if(VInternet = False)then
     begin
        Timer1.Interval := 5000;
        AddStatus('Sem conexão com a internet');
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

     AddStatus('Processo concluído!');
     Application.ProcessMessages;
     Sleep(2000);

     //ABRE O EXE DESEJADO
     if(VFechar = False)then Self.OpenGameExe;
   finally
   begin
      if(VInternet)or(VFechar)then
      begin
         WriteIniFile('APP', 'NAO');
         Self.LimparPastaDownload;
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
   AddStatus('Verificando arquivo de configuração');
   if not(FileExists(GetAppPath() + GetAppName() + '.ini'))then
   begin
      CriarArqConf;
   end;
   Application.ProcessMessages;
end;

procedure TFrmMain.ExisteArqLinks;
begin
   AddStatus('Verificando arquivo com os links');

   if not(FileExists(GetAppPath() + GetAppName() + '.txt'))then
   begin
      WriteTxtFile('404');
   end;

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
      DescompactFile(VPastaDownload + vnomeArq, VPastaExtrair);
      DeleteFile(VPastaDownload + vnomeArq);

      Application.ProcessMessages;
   end;

   AddStatus('Arquivos descompactados');
   Sleep(2000);
   Application.ProcessMessages;
end;

end.
