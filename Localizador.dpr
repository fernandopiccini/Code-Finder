program Localizador;

uses
  Forms,
  ULocalizador in 'ULocalizador.pas' {frmLocalizador},
  UDiretorio in 'UDiretorio.pas' {frmDiretorio},
  UConfiguracao in 'UConfiguracao.pas' {frmConfiguracao};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLocalizador, frmLocalizador);
  Application.Run;
end.
