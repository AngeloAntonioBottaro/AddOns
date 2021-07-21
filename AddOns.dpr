program AddOns;

uses
  Vcl.Forms,
  AddOns.View.Principal in 'Src\View\AddOns.View.Principal.pas' {FrmMain},
  Vcl.Themes,
  Vcl.Styles,
  Helpers.Functions in '..\Bibliotecas\Helpers\Helpers.Functions.pas',
  SearchScreen.Controller in '..\Bibliotecas\SearchScreen\SearchScreen.Controller.pas',
  SearchScreen.View in '..\Bibliotecas\SearchScreen\SearchScreen.View.pas' {FrmBuscaComponentesTela},
  Msg.Controller in '..\Bibliotecas\Msg\Msg.Controller.pas',
  Msg.View in '..\Bibliotecas\Msg\Msg.View.pas' {FrmMensagem};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Amethyst Kamri');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmBuscaComponentesTela, FrmBuscaComponentesTela);
  Application.CreateForm(TFrmMensagem, FrmMensagem);
  Application.CreateForm(TFrmBuscaComponentesTela, FrmBuscaComponentesTela);
  Application.CreateForm(TFrmMensagem, FrmMensagem);
  Application.Run;
end.
