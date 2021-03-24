program AddOns;

uses
  Vcl.Forms,
  UntMain in 'UntMain.pas' {FrmMain},
  UntBibliotecaFuncoes in 'D:\Biblioteca\UntBibliotecaFuncoes.pas',
  UntBuscaComponentes in 'D:\Biblioteca\UntBuscaComponentes.pas',
  UntBuscaComponentesTela in 'D:\Biblioteca\UntBuscaComponentesTela.pas' {FrmBuscaComponentesTela},
  UntMensagem in 'D:\Biblioteca\UntMensagem.pas' {FrmMensagem},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Silver');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmMensagem, FrmMensagem);
  Application.CreateForm(TFrmBuscaComponentesTela, FrmBuscaComponentesTela);
  Application.CreateForm(TFrmBuscaComponentesTela, FrmBuscaComponentesTela);
  Application.CreateForm(TFrmMensagem, FrmMensagem);
  Application.Run;
end.
