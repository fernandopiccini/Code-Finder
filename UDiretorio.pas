unit UDiretorio;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, ExtCtrls, Buttons, IniFiles, jpeg, Grids,
  Outline, ComCtrls, ShellCtrls, DirOutln, sSpeedButton, sBevel, sLabel;

type
  TfrmDiretorio = class(TForm)
    Dir_lb: TsLabel;
    Bevel1: TsBevel;
    Bevel2: TsBevel;
    CancelarBtn: TsSpeedButton;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    okBtn: TsSpeedButton;
    procedure FormActivate(Sender: TObject);
    procedure CancelarBtnClick(Sender: TObject);
    procedure okBtnClick(Sender: TObject);
    procedure DirectoryListBox1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FPathAux: String;
  public
    { Public declarations }
  end;

var
  frmDiretorio: TfrmDiretorio;

implementation

uses ULocalizador;

{$R *.dfm}

{ TfrmDiretorio }


procedure TfrmDiretorio.FormActivate(Sender: TObject);
begin
  if (Assigned(frmLocalizador.FileIni)) then
     begin
     Dir_lb.Caption := frmLocalizador.FileIni.ReadString('Configuração', 'DirInicial', 'C:');
     FPathAux := Dir_lb.Caption;
     end;
end;

procedure TfrmDiretorio.CancelarBtnClick(Sender: TObject);
begin
  Dir_lb.Caption := FPathAux;
  Close;
end;

procedure TfrmDiretorio.okBtnClick(Sender: TObject);
begin
  if (Assigned(frmLocalizador.FileIni)) then
      frmLocalizador.FileIni.WriteString('Configuração', 'DirInicial', Dir_lb.Caption);
  Close;
end;

procedure TfrmDiretorio.DirectoryListBox1KeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key = #13) then
     okBtnClick(Nil);
end;

end.
