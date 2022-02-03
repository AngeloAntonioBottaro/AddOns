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
    procedure OnStatus(AMsg: string);
  public
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

uses
  Controller.Factory,
  Model.Utils;

{$R *.dfm}


procedure TViewPrincipal.FormCreate(Sender: TObject);
begin
   ReportMemoryLeaksOnShutdown := True;
   FController  := TController.New;
   Self.Caption := Self.Caption + Model.Utils.SystemVersion;
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
     .OnShowName(Self.OnShowName)
     .OnStatus(Self.OnStatus)
     .ConfigurationLoad
     .LinksLoad
     .DownloadFiles
     .ExtractDownloadedFiles;

   TimerShow.Enabled  := True;
   TimerShow.Interval := 60000;

   if(Model.Utils.VFechar)then
     Application.Terminate;
end;

procedure TViewPrincipal.OnShowName(AName: string);
begin
   lbNome.Caption := AName;
end;

procedure TViewPrincipal.OnStatus(AMsg: string);
begin
   StatusBar.Panels[0].Text := AMsg;
   Application.ProcessMessages;
end;

end.
