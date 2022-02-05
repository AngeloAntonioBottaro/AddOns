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
   Model.Utils.CleanVariables;
   Self.Caption := Self.Caption + Model.Utils.SystemVersion;
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
   if(FileExists(CArquivoLock)and(not VAppRunning))then
     DeleteFile(CArquivoLock);

   FController
    .Sistema
     .OnShowName(Self.OnShowName)
     .OnStatus(Self.OnStatus)
     .VerifyApplicationOpen
     .ConfigurationLoad
     .LinksLoad
     .DownloadFiles
     .ExtractDownloadedFiles
     .CloseBrowser
     .CloseSystem;

   if(Model.Utils.VFechar)then
     Self.Close
   else
   begin
      TimerShow.Interval := 5000;
      TimerShow.Enabled  := True;
      Self.OnStatus('Nova tentativa em 5 segundos');
   end;
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
