unit UConfiguracao;
                  
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, ComCtrls, CheckLst, IniFiles,
  sSpeedButton, sBevel, sPanel;

type
  TfrmConfiguracao = class(TForm)
    Panel1: TsPanel;
    Bevel1: TsBevel;
    btnGravar: TSspeedButton;
    CheckListBox: TCheckListBox;
    Bevel2: TsBevel;
    btnSair: TsSpeedButton;
    btnAbrir: TsSpeedButton;
    procedure FormActivate(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure CheckListBoxClick(Sender: TObject);
    procedure btnAbrirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfiguracao: TfrmConfiguracao;

implementation

uses ShellApi, ULocalizador;

{$R *.dfm}

procedure TfrmConfiguracao.FormActivate(Sender: TObject);
var
  I: Byte;
begin
  try
    if (Assigned(frmLocalizador.FileIni)) then
      for I := 0 to 4 do
        CheckListBox.Checked[I] := (frmLocalizador.FileIni.ReadString('Configuração', CheckListBox.Items[I], '') = 'True')
    else
      MessageDlg('Arquivo ' + frmLocalizador.FileStrIni + ' não foi localizado!', MtInformation, [MbOk], 0);
  except
    MessageDlg(Exception(ExceptObject).Message, MtInformation, [MbOk], 0);
  end;
end;

procedure TfrmConfiguracao.btnGravarClick(Sender: TObject);
var
  I: Byte;
begin
  try
    if (Assigned(frmLocalizador.FileIni)) then
       begin
       for I := 0 to 4 do
         if (CheckListBox.Checked[I]) then
            frmLocalizador.FileIni.WriteString('Configuração', CheckListBox.Items[I], 'True')
         else
            frmLocalizador.FileIni.WriteString('Configuração', CheckListBox.Items[I], 'False');
       frmLocalizador.Gravar_Vetor;
       MessageDlg('Arquivo Gravado com Sucesso!', MtInformation, [MbOk], 0);
       Close;
       end
    else
       MessageDlg('Arquivo ' + frmLocalizador.FileStrIni + ' não foi localizado!', MtInformation, [MbOk], 0);
  except
    MessageDlg(Exception(ExceptObject).Message, MtInformation, [MbOk], 0);
  end;
end;

procedure TfrmConfiguracao.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConfiguracao.CheckListBoxClick(Sender: TObject);
begin
  if CheckListBox.Checked[4] then
     frmLocalizador.Diretorio_ed.Text := frmLocalizador.FileIni.ReadString('Configuração', 'DirInicialJava', '')
  else
     frmLocalizador.Diretorio_ed.Text := frmLocalizador.FileIni.ReadString('Configuração', 'DirInicial', '');
end;

procedure TfrmConfiguracao.btnAbrirClick(Sender: TObject);
begin
  ShellExecute(GetActiveWindow, 'open', PChar(frmLocalizador.FileStrIni), Nil, Nil, SW_SHOW);
end;

end.
