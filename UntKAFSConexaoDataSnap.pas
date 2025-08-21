unit UntKAFSConexaoDataSnap;

interface

uses
  System.Classes, System.UITypes,
  FMX.DialogService, FMX.Forms,
  Data.SqlExpr;

type
  TKAFSConexaoDataSnap = class(TSQLConnection)

    constructor Create(AOwner: TComponent); reintroduce;
    procedure Conectar;
    procedure Desconectar;
    destructor Destroy; override;
  end;

implementation

uses
  UntKAFSFuncoes;

constructor TKAFSConexaoDataSnap.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Configura o componente para DataSnap
  DriverName := 'Datasnap';

  // Desabilita janela de login padr�o
  LoginPrompt := False;

  // Configura par�metros para DataSnap
  Params.Values['CommunicationProtocol'] := 'tcp/ip';
  Params.Values['DatasnapContext'] := 'datasnap/';

  // Configura timeout
  Params.Values['CommunicationTimeout'] := '10000';
  Params.Values['ConnectionIdleTimeout'] := '30000';
  Params.Values['ConnectTimeout'] := '5000';
end;

procedure TKAFSConexaoDataSnap.Conectar;
begin
  var _sair := False;
  {$IF Defined(ANDROID)}
  // Vari�vel de controle para saber quando o usu�rio termina a tela de dialogo
  var _respondido := False;
  {$ENDIF}

  // Repete enquanto n�o conseguir conex�o e n�o estiver pronto para finalizar
  while (not Connected) and (not _sair) do
    try
      // Busca em cache local o endere�o do servidor
      Params.Values['HostName'] := LerIni('cache', 'servidor', 'host');
      Params.Values['Port'] := LerIni('cache', 'servidor', 'porta');

      // Tentativa de conex�o
      Connected := True;
    except
      // Caso a tentativa fracasse
      TThread.Synchronize(nil, procedure
      begin
        TDialogService.InputQuery('Servidor n�o encontrado', ['IP', 'Porta'], ['', ''], procedure(const AResult: TModalResult; const AValues: array of string)
        begin
          if AResult = mrOk then
          begin
            SalvarIni('cache', 'servidor', 'host', AValues[0]);
            SalvarIni('cache', 'servidor', 'porta', AValues[1]);

            {$IF Defined(ANDROID)}
            _resposta := True;
            {$ENDIF}
          end
          else
            Application.Terminate;
        end);
      end);

      {$IF Defined(ANDROID)}
      // No Android a tela de dialogo n�o pausa o c�digo
      while not _respondido do
        Sleep(100);
      {$ENDIF}
    end;
end;
procedure TKAFSConexaoDataSnap.Desconectar;
begin
  Connected := False;
end;

destructor TKAFSConexaoDataSnap.Destroy;
begin
  Desconectar;

  inherited Destroy;
end;

end.
