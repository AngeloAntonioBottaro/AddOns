program AddOns;

uses
  Vcl.Forms,
  UntMain in 'UntMain.pas' {FrmMain},
  uCComunicacao in 'D:\Biblioteca\uCComunicacao.pas',
  UntBibliotecaFuncoes in 'D:\Biblioteca\UntBibliotecaFuncoes.pas',
  UntBuscaComponentes in 'D:\Biblioteca\UntBuscaComponentes.pas',
  UntBuscaComponentesTela in 'D:\Biblioteca\UntBuscaComponentesTela.pas' {FrmBuscaComponentesTela},
  UntConstantes in 'D:\Biblioteca\UntConstantes.pas',
  UntImpressaoTermica in 'D:\Biblioteca\UntImpressaoTermica.pas',
  UntMensagem in 'D:\Biblioteca\UntMensagem.pas' {FrmMensagem},
  UntTypes in 'D:\Biblioteca\UntTypes.pas',
  UntVariaveis in 'D:\Biblioteca\UntVariaveis.pas',
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
