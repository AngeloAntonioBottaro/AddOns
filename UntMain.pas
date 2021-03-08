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
    procedure AddStatus(pStr: string);
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

procedure TFrmMain.FormShow(Sender: TObject);
begin
   Timer1.Enabled := True;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
var
  i, vTotItens: Integer;
  vPastaDownload, vPastaExtrair: string;
  vnomeArq, vStr: string;
  vArq: TextFile;
  vCaminhoNome: string;
  vCaminhoExecutavel: string;
  vBrowser: string;
begin
   Timer1.Enabled := False;
   vTotItens := 0;

   AddStatus('Verificando arquivos de configuração');
   vCaminhoNome := GetAppPath() + GetAppName();
   //VERIFICA SE EXITE OS ARQUIVOS DE CONFIGURACAO E COM OS LINKS
   if not(FileExists(vCaminhoNome + '.ini'))then
   begin
      WriteIniFile('NOME', 'Configurar');
      WriteIniFile('PASTADOWNLOAD', SelectDir('Selecione a pasta dos downloads'));
      WriteIniFile('PASTAEXTRAIR', SelectDir('Selecione a pasta onde os arquivos serão extraidos'));
      WriteIniFile('BROWSER','msedge.exe');
      OpenDialog.Title := 'Selecine o executavel que será aberto';
      if(OpenDialog.Execute())then
      begin
         vCaminhoExecutavel := OpenDialog.FileName;
         WriteIniFile('EXECUTAVEL', vCaminhoExecutavel);
      end;
   end;

   lbNome.Caption     := ReadIniFileStr('NOME');
   vPastaDownload     := ReadIniFileStr('PASTADOWNLOAD');
   vPastaExtrair      := ReadIniFileStr('PASTAEXTRAIR');
   vCaminhoExecutavel := Trim(ReadIniFileStr('EXECUTAVEL'));
   vBrowser           := ReadIniFileStr('BROWSER');

   Application.ProcessMessages;
   AssignFile(vArq, vCaminhoNome + '.txt');
   if not(FileExists(vCaminhoNome + '.txt'))then
   begin
      Rewrite(vArq);
      Writeln(vArq,'1');
      CloseFile(vArq);
   end;
   Application.ProcessMessages;
   Reset(vArq);

   //VERIFICA SE FOI REALIZADO AS CONFIGURACOES
   if(ReadIniFileStr('NOME') = 'Configurar')then
   begin
      AddStatus('Configuração necessária');
      Sleep(3000);
      FrmMain.Close;
      Exit;
   end;

   //LIMPA A PASTA DOWNLOAD
   AddStatus('Limpando pasta de downloads');
   ListFiles(Memo1, vPastaDownload);
   for I := 0 to Memo1.Lines.Count do
   begin
      vnomeArq := ExtractFileName(Memo1.Lines[i]);
      //DELETA OS ARQUIVOS
      DeleteFile(vPastaDownload + vnomeArq);
      Application.ProcessMessages;
   end;

   //VERIFICA SE ESTA CONECTADO COM A INTERNET PARA PODER BAIXAR OS ARQUIVOS
   AddStatus('Verificando conexão da internet');
   if(InternetConnection = False)then
   begin
      Timer1.Interval := 60000;
      AddStatus('Sem conexão com a internet');
      Timer1.Enabled := True;
      Exit;
   end;

   //PERCORRE OS LINKS BAIXANDO TODOS
   AddStatus('Baixando arquivos');
   while Eof(vArq) = False do
   begin
      Readln(vArq, vStr);
      if(Trim(vStr) <> '')then
      begin
         OpenLink(vStr, tpAbrirLinkIvisivel);
         Application.ProcessMessages;
         Sleep(3000);
         IncInt(vTotItens);
         Application.ProcessMessages;
      end;
   end;
   CloseFile(vArq);
   Sleep(5000);

   //LISTA OS ARQUIVOS BAIXADOS
   Application.ProcessMessages;
   Memo1.Lines.Clear;
   while(vTotItens <> Memo1.Lines.Count)do
   begin
      Sleep(2000);
      ListFiles(Memo1, vPastaDownload, 'zip');
   end;
   AddStatus('Arquivos baixados');

   //FECHA O BROWSER
   if(vBrowser <> '')then
   begin
      CloseEXE(vBrowser);
      Sleep(5000);
   end;

   //EXTRAI OS ARQUIVOS PARA A PASTA SELECIONADA
   AddStatus('Extraindo arquivos para: ' + vPastaExtrair);
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

   //ABRE O EXE DESEJADO
   if(vCaminhoExecutavel <> '')then
   begin
      Application.ProcessMessages;
      Sleep(2000);
      OpenLink(vCaminhoExecutavel);
      Application.ProcessMessages;
   end;

   Application.ProcessMessages;
   FrmMain.Close;
end;

end.
