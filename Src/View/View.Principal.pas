unit View.Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Controller.Interfaces;

const
   Versao    = 1;
   SubVersao = 0;

type
  TViewPrincipal = class(TForm)
    TimerShow: TTimer;
    StatusBar: TStatusBar;
    lbNome: TLabel;
    ImgClose: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerShowTimer(Sender: TObject);
    procedure ImgCloseClick(Sender: TObject);
  private
    FController: iController;

    procedure OnShowName(AName: string);
    procedure OnMsg(AMsg: string);
    procedure OnStatus(AMsg: string);
  public
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

uses
  Controller.Factory, Model.Utils;

{$R *.dfm}


procedure TViewPrincipal.FormCreate(Sender: TObject);
begin
   ReportMemoryLeaksOnShutdown := True;
   Self.Caption := Self.Caption + '  - Vers�o: ' + Versao.ToString + '.' + SubVersao.ToString;
   FController  := TController.New;
end;

procedure TViewPrincipal.FormShow(Sender: TObject);
begin
   TimerShow.Enabled := True;
end;

procedure TViewPrincipal.ImgCloseClick(Sender: TObject);
begin
   Model.Utils.VFechar := True;
   self.OnStatus('Fechando sistema');
end;

procedure TViewPrincipal.TimerShowTimer(Sender: TObject);
begin
   TimerShow.Enabled := False;

   FController
    .Sistema
     .ConfigurationLoad
     .LinksLoad;

   TimerShow.Enabled  := True;
   TimerShow.Interval := 60000;

   if(Model.Utils.VFechar)then
     Application.Terminate;
end;

procedure TViewPrincipal.OnShowName(AName: string);
begin
   lbNome.Caption := AName;
end;

procedure TViewPrincipal.OnMsg(AMsg: string);
begin
   ShowMessage(AMsg);
end;

procedure TViewPrincipal.OnStatus(AMsg: string);
begin
   StatusBar.Panels[0].Text := AMsg;
   Application.ProcessMessages;
end;

end.
