unit ULocalizador;

interface

uses
  Windows, Messages, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, CheckLst, Buttons, Spin, ComCtrls,
  IniFiles,ShellAPI, DB, DBClient, Grids, DBGrids, SysUtils, DBCtrls,
  FileCtrl, sSkinManager, sLabel, sEdit, sSpeedButton, sBevel, acDBGrid,
  sStatusBar;

type
  TfrmLocalizador = class(TForm)
    DataSource1: TDataSource;
    ClientDataSet: TClientDataSet;
    sSkinManager1: TsSkinManager;
    Bevel1: TsBevel;
    Bevel3: TsBevel;
    Localizador_dir_btn: TsSpeedButton;
    btnConfiguracao: TsSpeedButton;
    BtnLocalizar: TsSpeedButton;
    btnLimpar: TsSpeedButton;
    btnEditar: TsSpeedButton;
    btnSair: TsSpeedButton;
    btnCancelar: TsSpeedButton;
    sLabelFX1: TsLabelFX;
    sLabelFX2: TsLabelFX;
    Texto_ed: TsEdit;
    Diretorio_ed: TsEdit;
    DBGrid1: TsDBGrid;
    Animate1: TAnimate;
    sStatusBar1: TsStatusBar;
    lbText: TsLabel;
    procedure btnSairClick(Sender: TObject);                           
    procedure btnEditarClick(Sender: TObject);
    procedure BtnLocalizarClick(Sender: TObject);
    procedure Diretorio_edKeyPress(Sender: TObject; var Key: Char);
    procedure Diretorio_edDblClick(Sender: TObject);
    procedure Pesquisar_Arquivo(Ext: String);
    procedure FormDestroy(Sender: TObject);
    procedure btnConfiguracaoClick(Sender: TObject);
    procedure Texto_edKeyPress(Sender: TObject; var Key: Char);
    procedure Arquivos_mmDblClick(Sender: TObject);
    procedure ClearClientDataSet;
    procedure btnLimparClick(Sender: TObject);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    { Private declarations }
    Rich: TRichEdit;
    VetorExt: array[1..5] of String;
    VetorVal: array[1..5] of String;
  public
    { Public declarations }
    FileIni: TIniFile;
    FileStrIni,
    FileStrXml: String;
    procedure Gravar_Vetor;
    function FindFile(const filespec: TFileName; attributes: integer = faReadOnly Or faHidden Or faSysFile Or faArchive): TStringList;
  end;

var
  frmLocalizador: TfrmLocalizador;

implementation

uses
  UDiretorio, UConfiguracao;

{$R *.dfm}

function TfrmLocalizador.FindFile(const filespec: TFileName; attributes: integer): TStringList;
var
  spec: string;
  list: TStringList;

  procedure RFindFile(const folder: TFileName);
  var
    SearchRec: TSearchRec;
  begin
    if FindFirst(folder + spec, attributes, SearchRec) =0 then
      begin
        try
          repeat
            if (SearchRec.Attr and faDirectory = 0) or
               (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
               List.Add(folder + SearchRec.Name);
          until FindNext(SearchRec) <> 0;
        except
          FindClose(SearchRec);
          raise;
        end;
        FindClose(SearchRec);
    end;

    if FindFirst(folder + '*', attributes or faDirectory, SearchRec) = 0 then
      begin
        try
          repeat
            if ((SearchRec.Attr and faDirectory) <> 0) and
               (SearchRec.Name<>'.') and (SearchRec.Name <> '..') then
              RFindFile(folder + SearchRec.Name + '\');
          until FindNext(SearchRec) <> 0;
        except
          FindClose(SearchRec);
          raise;
        end;
        FindClose(SearchRec);
      end;
  end;

  begin
    list := TStringList.Create;
    try
      spec := ExtractFileName(filespec);
      RFindFile(ExtractFilePath(filespec));
      Result := list;
    except
      list.Free;
      raise;
    end;
end;

procedure TfrmLocalizador.btnSairClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLocalizador.btnEditarClick(Sender: TObject);

  function ExtractSystemDir : String;
  var
    Buffer : Array[0..255] of Char;
  begin
    GetSystemDirectory(Buffer,144);
    Result := StrPas(Buffer);
  end;

begin
  if (not ClientDataSet.IsEmpty) then
     begin
     if (ExtractFileExt(ClientDataSet.FieldByName('Arquivo').AsString) = '.sql') or
        (ExtractFileExt(ClientDataSet.FieldByName('Arquivo').AsString) = '.java') or
        (ExtractFileExt(ClientDataSet.FieldByName('Arquivo').AsString) = '.txt') then
        WinExec(PChar(ExtractSystemDir + '\Rundll32.exe ' + ExtractSystemDir + '\shell32.dll, ShellExec_RunDLL ' +
                ClientDataSet.FieldByName('Arquivo').AsString), SW_SHOW)
     else
        ShellExecute(GetActiveWindow, 'open', PChar(ExtractFileName(ClientDataSet.FieldByName('Arquivo').AsString)), '',
                     PChar(ExtractFilePath(ClientDataSet.FieldByName('Arquivo').AsString)), 0);
     end;
{     keybd_event(VK_CONTROL, 1, 0, 0);
     keybd_event(VK_HOME, 1, 0, 0);
     keybd_event(VK_HOME, 1, KEYEVENTF_KEYUP, 0);
     keybd_event(VK_CONTROL, 1, KEYEVENTF_KEYUP, 0);
     for I := 2 to ClientDataSet.FieldByName('Linha').AsInteger do
         keybd_event(VK_DOWN, 1, 0, 0);
     keybd_event(VK_SHIFT, 1, 0, 0);
     keybd_event(vk_end, 1, 1, 0);
     keybd_event(vk_end, 1, KEYEVENTF_KEYUP	, 0);
     keybd_event(VK_SHIFT, 1, KEYEVENTF_KEYUP, 0);
     end;}
end;

procedure TfrmLocalizador.BtnLocalizarClick(Sender: TObject);
var
  I: Byte;
begin
  ClearClientDataSet;
  ClientDataSet.Active := True;
  if (Trim(Texto_ed.Text) = '') then
     MessageDlg('Campo texto não informado!', MtInformation, [MbOk], 0)
  else
    if ((DirectoryExists(Diretorio_ed.Text)) and
       (DirectoryExists(Diretorio_ed.Text + '\'))) then
       try
         Animate1.Visible := True;
         Animate1.Active  := True;
         btnCancelar.Visible := True;
         Screen.Cursor := crHourGlass;
         for I := 1 to High(VetorVal) do
           if (LowerCase(VetorVal[I]) = 'true') then
              Pesquisar_Arquivo(VetorExt[I]);
         Screen.Cursor := crDefault;
         Animate1.Active := False;
         Animate1.Visible := False;
         btnCancelar.Visible := False;
         if (ClientDataSet.RecordCount <= 0) then
            MessageDlg('Não foi localizado nenhum arquivo!', MtInformation, [MbOk], 0)
       except
         Animate1.Active := False;
         Animate1.Visible := False;
         btnCancelar.Visible := False;
         MessageDlg(Exception(ExceptObject).Message, MtInformation, [MbOk], 0);
       end
    else
      MessageDlg('Verifique se o seguinte é um diretório válido! ' + Diretorio_ed.Text, MtInformation, [MbOk], 0);
end;

procedure TfrmLocalizador.Diretorio_edKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then
     Diretorio_edDblClick(Nil);
end;

procedure TfrmLocalizador.Diretorio_edDblClick(Sender: TObject);
begin                                   
  try
    Application.CreateForm(TfrmDiretorio, frmDiretorio);
    frmDiretorio.ShowModal;
    Diretorio_ed.Text := frmDiretorio.Dir_lb.Caption;
    frmDiretorio.Destroy;
  except
  end;
end;

procedure TfrmLocalizador.FormDestroy(Sender: TObject);
begin
  try
    if (Assigned(FileIni)) then
       begin
       FileIni.Free;
       FileIni := Nil;
       end;
    ClientDataSet.Close;
  except
  end;
end;

procedure TfrmLocalizador.Pesquisar_Arquivo(Ext: String);
var
  Lista: TStringList;
  I, J : Integer;
  Str, ch: String;
  Arq: TextFile;
begin
  Lista := FindFile(Diretorio_ed.Text + '\*.' + Ext);
  for J := 0 to Lista.Count - 1 do
     begin
     lbText.caption := Lista.strings[J];
     {$I-}
     AssignFile(Arq, Lista.strings[J]);
     FileMode := 0;
     Reset(Arq);
     Str := LowerCase(Texto_ed.Text);
     I := 0;
     if (not btnCancelar.Visible) then
        Exit;
     while not Eof(Arq) do
        begin
        Inc(I);
        Readln(Arq, Ch);
        if (Pos(Str, LowerCase(Ch)) > 0) then
           begin
           ClientDataSet.Insert;
           ClientDataSet.FieldByName('Linha').AsInteger := I;
           ClientDataSet.Fieldbyname('Arquivo').AsString:= Lista.strings[J];
           ClientDataSet.Fieldbyname('Tipo').AsString:= Ext;
           ClientDataSet.Post;
           Break;
           end;
        end;
     CloseFile(Arq);
     {$I+}
     Application.ProcessMessages;
     end;
  lbText.Caption := '';
end;

procedure TfrmLocalizador.btnConfiguracaoClick(Sender: TObject);
begin
  try
    Application.CreateForm(TfrmConfiguracao, frmConfiguracao);
    frmConfiguracao.ShowModal;
    frmConfiguracao.Destroy;
  except
    MessageDlg(Exception(ExceptObject).Message, MtInformation, [MbOk], 0);
  end;
end;

procedure TfrmLocalizador.Texto_edKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then
     BtnLocalizarClick(Nil);
end;

procedure TfrmLocalizador.Arquivos_mmDblClick(Sender: TObject);
begin
  btnEditarClick(Nil);
end;

procedure TfrmLocalizador.ClearClientDataSet;
begin
  ClientDataSet.Active := True;
  ClientDataSet.DisableControls;
  while not ClientDataSet.Eof do
    begin
    ClientDataSet.Delete;
    ClientDataSet.Next;
    end;
  ClientDataSet.EmptyDataSet;
  ClientDataSet.EnableControls;
end;

procedure TfrmLocalizador.btnLimparClick(Sender: TObject);
begin
  ClearClientDataSet;
end;

procedure TfrmLocalizador.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
     btnEditarClick(Nil);
end;                         

procedure TfrmLocalizador.Gravar_Vetor;
begin
  VetorExt[1] := 'PAS';
  VetorExt[2] := 'DFM';
  VetorExt[3] := 'SQL';
  VetorExt[4] := 'TXT';
  VetorExt[5] := 'JAVA';
  VetorVal[1] := FileIni.ReadString('Configuração', VetorExt[1], '');
  VetorVal[2] := FileIni.ReadString('Configuração', VetorExt[2], '');
  VetorVal[3] := FileIni.ReadString('Configuração', VetorExt[3], '');
  VetorVal[4] := FileIni.ReadString('Configuração', VetorExt[4], '');
  VetorVal[5] := FileIni.ReadString('Configuração', VetorExt[5], '');
end;

procedure TfrmLocalizador.FormCreate(Sender: TObject);
var
  I: Integer;
  FileAux: TStrings;
begin
  try
    FileStrIni := ExtractFilePath(Application.ExeName) + 'Localizador.ini';
    FileStrXml := ExtractFilePath(Application.ExeName) + 'Localizador.xml';
    ClientDataSet.FileName := FileStrXml;
    if not FileExists(FileStrXml) then
       begin
       ClientDataSet.Close;
       for I := ClientDataSet.FieldDefs.Count - 1 downto 0 do
         ClientDataSet.FieldDefs.Delete(I);
       with ClientDataSet.FieldDefs.AddFieldDef do
         begin
         DataType := ftInteger;
         Name     := 'Linha';
         end;
       with ClientDataSet.FieldDefs.AddFieldDef do
         begin
         DataType := ftString;
         Size     := 255;
         Name     := 'Arquivo';
         end;
       with ClientDataSet.FieldDefs.AddFieldDef do
         begin
         DataType := ftString;
         Size     := 4;
         Name     := 'Tipo';
         end;
       ClientDataSet.CreateDataSet;
       ClientDataSet.SaveToFile(FileStrXml, dfXML);
       end;
  except
    MessageDlg(Exception(ExceptObject).Message, MtInformation, [MbOk], 0);
  end;
  if (not FileExists(FileStrIni)) then
     try
       FileAux := TStringList.Create;
       FileAux.Add('[Configuração]');
       FileAux.Add('DirInicial=' + ExtractFilePath(Application.ExeName));
       FileAux.Add('DirInicialJava=\\whebd12\java\Projetos\WhebServidor\src\java');
       FileAux.Add('PAS=True');
       FileAux.Add('DFM=False');
       FileAux.Add('SQL=False');
       FileAux.Add('TXT=False');
       FileAux.Add('JAVA=False');
       FileAux.SaveToFile(FileStrIni);
       FileAux.Free;
     except
       MessageDlg(Exception(ExceptObject).Message, MtInformation, [MbOk], 0);
     end;
  try
    FileIni := TIniFile.Create(FileStrIni);
    Diretorio_ed.Text := FileIni.ReadString('Configuração', 'DirInicial', '');
    Gravar_Vetor;
  except
    MessageDlg(Exception(ExceptObject).Message, MtInformation, [MbOk], 0);
  end;
  ClientDataSet.Close;
end;

procedure TfrmLocalizador.btnCancelarClick(Sender: TObject);
begin
  btnCancelar.Visible := False;
end;

end.
