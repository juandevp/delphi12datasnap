unit UFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.Edit, REST.Backend.ServiceTypes, System.JSON,
  REST.Backend.EMSServices, FMX.StdCtrls, Data.Bind.Components,
  Data.Bind.ObjectScope, REST.Client, REST.Backend.EndPoint,
  REST.Backend.EMSProvider, REST.Types, REST.JSON, FMX.DateTimeCtrls,
  FMX.ListBox, Data.DB, Datasnap.DBClient, REST.Response.Adapter,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Generics.Collections,
  UEmpleado, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid,
  FMX.DialogService, FMX.ComboEdit;

type
  EnumEstadosForm = (EfAgregar, EfGuardar, EfEditar, EfEliminar, EfCancelar);

type
  TfrmPrincipal = class(TForm)
    EdNombres: TEdit;
    EdApellidos: TEdit;
    LblNombres: TLabel;
    LblApellidos: TLabel;
    BtnGuardar: TButton;
    rsEmpleado: TRESTResponse;
    rsrEmpleado: TRESTRequest;
    deFechaIngreso: TDateEdit;
    EdIdentificacion: TEdit;
    LblFechaIngreso: TLabel;
    LblIdentificacion: TLabel;
    LblCargo: TLabel;
    EdCargo: TEdit;
    cbListaDependencia: TComboBox;
    LblDependencia: TLabel;
    rsrListaDependencias: TRESTRequest;
    RESTSERV: TRESTClient;
    rsListaDependencias: TRESTResponse;
    rsListaEmpleados: TRESTResponse;
    rsrListaEmpleados: TRESTRequest;
    sgListaEmpleados: TStringGrid;
    fun_nid: TStringColumn;
    fun_cidentificacion: TStringColumn;
    fun_cnombres: TStringColumn;
    fun_capellidos: TStringColumn;
    fun_cargo: TStringColumn;
    fun_fecha_ingreso: TStringColumn;
    dep_nombredependencia: TStringColumn;
    BtnEliminar: TButton;
    BtnAgregar: TButton;
    BtnEditar: TButton;
    BtnCancelar: TButton;
    EdSec: TEdit;
    LblTitulo: TLabel;
    LblNota: TLabel;
    rsrEliminar: TRESTRequest;
    rsEliminar: TRESTResponse;
    Button1: TButton;
    rsDependencia: TRESTResponse;
    rsrDependencia: TRESTRequest;
    BtnExportar: TButton;

    procedure BtnGuardarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgListaEmpleadosSelectCell(Sender: TObject;
      const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure BtnAgregarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnEditarClick(Sender: TObject);
    procedure BtnEliminarClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BtnExportarClick(Sender: TObject);
  private
    FValoresColumn: array of TValue;
    FListaDependencias: TObjectList<TDependencia>;
    procedure LlenarComboDependencia;
    procedure LlenarListaEmpleados;
    function ObtenerDependenciaId(ANombreDependencia: string): Integer;
    function DescomponerResultado(AJsonValue: TJSONValue): TJSONValue;
    procedure AsignarValoresCampos(AIDentificacion, ANombres, AApellidos,
      ACargo, AFechaIngreso, ADependencia, AId: string);
    procedure CambiarEstadoBotones(AEstado: EnumEstadosForm);
    procedure ValidarCampos;
    function GenerarModeloGuardarEditar(AResquest: TRESTRequest;
      AMethod: TRESTRequestMethod): string;
    function GenerarModelGuardarEditarDependencia(AResquest: TRESTRequest;
      AMethod: TRESTRequestMethod; ANombreDependencia: string): string;
    procedure ReiniciarProceso;
    function AceptaContinuarProceso: Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

function TfrmPrincipal.GenerarModelGuardarEditarDependencia(AResquest: TRESTRequest;
  AMethod: TRESTRequestMethod; ANombreDependencia: string): string;
var
  Dependencia: TDependencia;
  IdSecuencia: Integer;
begin
  if Trim(ANombreDependencia) = EmptyStr then
  begin
    raise Exception.Create('Por favor, ingresar información de dependencia');
  end;

  TryStrToInt('', IdSecuencia);
  Dependencia := TDependencia.Create(IdSecuencia, ANombreDependencia);
  try
    Result := TJson.ObjectToJsonString(Dependencia, [joSerialFields]);
    AResquest.ClearBody;
    AResquest.Method := AMethod;
    AResquest.Body.Add(Result, TRESTContentType.ctAPPLICATION_JSON);
    AResquest.Execute;
    LlenarComboDependencia;
    ShowMessage(DescomponerResultado(AResquest.Response.JSONValue)
      .GetValue<string>);
  finally
    Dependencia.Free;
  end;
end;

function TfrmPrincipal.AceptaContinuarProceso: Boolean;
var
  RespuestaModal: Boolean;
begin
  TDialogService.MessageDialog('¿Desea continuar con el proceso?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      RespuestaModal := AResult = mrYes;
    end);
  Result := RespuestaModal;
end;

procedure TfrmPrincipal.ReiniciarProceso;
begin
  AsignarValoresCampos(EmptyStr, EmptyStr, EmptyStr, EmptyStr, DateToStr(Date),
    EmptyStr, EmptyStr);
  CambiarEstadoBotones(EfCancelar);
end;

function TfrmPrincipal.GenerarModeloGuardarEditar(AResquest: TRESTRequest;
AMethod: TRESTRequestMethod): string;
var
  Empleado: TEmpleado;
  IdSecuencia: Integer;
begin
  ValidarCampos;
  Empleado := TEmpleado.Create;
  try
    TryStrToInt(EdSec.Text, IdSecuencia);
    Empleado.fun_nid := IdSecuencia;
    Empleado.fun_cidentificacion := EdIdentificacion.Text;
    Empleado.fun_cnombres := EdNombres.Text;
    Empleado.fun_capellidos := EdApellidos.Text;
    Empleado.fun_cargo := EdCargo.Text;
    Empleado.fun_dep_nid := ObtenerDependenciaId(cbListaDependencia.Text);
    Empleado.fun_fecha_ingreso := deFechaIngreso.Text;
    Result := TJson.ObjectToJsonString(Empleado, [joSerialFields]);
    AResquest.ClearBody;
    AResquest.Method := AMethod;
    AResquest.Body.Add(Result, TRESTContentType.ctAPPLICATION_JSON);
    AResquest.Execute;
    LlenarListaEmpleados;
    ShowMessage(DescomponerResultado(AResquest.Response.JSONValue)
      .GetValue<string>);
  finally
    Empleado.Free;
  end;
end;

procedure TfrmPrincipal.ValidarCampos;
const
  ValorDefault = 'Por favor, ingresar información en el campo => ';
begin
  if Trim(EdNombres.Text) = EmptyStr then
  begin
    raise Exception.Create(ValorDefault + 'Nombres');
  end;
  if Trim(EdApellidos.Text) = EmptyStr then
  begin
    raise Exception.Create(ValorDefault + 'Apelldios');
  end;
  if Trim(deFechaIngreso.Text) = EmptyStr then
  begin
    raise Exception.Create(ValorDefault + 'Fecha Ingreso');
  end;
  if Trim(EdIdentificacion.Text) = EmptyStr then
  begin
    raise Exception.Create(ValorDefault + 'Indentificación');
  end;
  if Trim(EdCargo.Text) = EmptyStr then
  begin
    raise Exception.Create(ValorDefault + 'Cargo del funcionario');
  end;
  if Trim(cbListaDependencia.Text) = EmptyStr then
  begin
    raise Exception.Create(ValorDefault + 'Dependencia');
  end;
end;

procedure TfrmPrincipal.CambiarEstadoBotones(AEstado: EnumEstadosForm);
begin
  BtnAgregar.Enabled := (AEstado in [EfCancelar]);
  BtnGuardar.Enabled := (AEstado in [EfAgregar]);
  BtnEditar.Enabled := (AEstado in [EfEditar]);
  BtnEliminar.Enabled := (AEstado in [EfEditar]);
  BtnCancelar.Enabled := (AEstado in [EfAgregar, EfEditar]);
end;

procedure TfrmPrincipal.LlenarListaEmpleados;
var
  I: Integer;
  ListaEmpleados: TJSONArray;
  Value: TJSONValue;
  Registro: Integer;
begin
  rsrListaEmpleados.Execute;
  ListaEmpleados := DescomponerResultado(rsListaEmpleados.JSONValue)
    .GetValue<TJSONArray>;
  Registro := -1;
  sgListaEmpleados.RowCount := ListaEmpleados.Count;
  for Value in ListaEmpleados do
  begin
    Inc(Registro);
    for I := 0 to sgListaEmpleados.ColumnCount - 1 do
    begin
      sgListaEmpleados.Cells[I, Registro] :=
        Value.GetValue<string>(sgListaEmpleados.Columns[I].Name);
    end;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FListaDependencias := TObjectList<TDependencia>.Create;
  AsignarValoresCampos(EmptyStr, EmptyStr, EmptyStr, EmptyStr, DateToStr(Date),
    EmptyStr, EmptyStr);
  CambiarEstadoBotones(EfCancelar);
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  FListaDependencias.Free;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);

begin
  LlenarComboDependencia;
  LlenarListaEmpleados;
end;

function TfrmPrincipal.DescomponerResultado(AJsonValue: TJSONValue): TJSONValue;
begin
  Result := AJsonValue.GetValue<TJSONArray>('result')[0];
end;

procedure TfrmPrincipal.LlenarComboDependencia;
var
  ListaDependencias: TJSONArray;
  Value: TJSONValue;
begin
  //
  FListaDependencias.Clear;
  rsrListaDependencias.Execute;
  ListaDependencias := DescomponerResultado(rsListaDependencias.JSONValue)
    .GetValue<TJSONArray>;

  for Value in ListaDependencias do
  begin
    var
    Dependencia := TDependencia.Create(Value.GetValue<Integer>('dep_nid'),
      Value.GetValue<string>('dep_nombredependencia'));
    FListaDependencias.Add(Dependencia);
    cbListaDependencia.Items.Add(Dependencia.dep_nombredependencia);
  end;

end;

function TfrmPrincipal.ObtenerDependenciaId(ANombreDependencia: string): Integer;
var
  Dependencia: TDependencia;
begin
  Result := -1;
  for Dependencia in FListaDependencias do
  begin
    if Dependencia.dep_nombredependencia = ANombreDependencia then
    begin
      Result := Dependencia.dep_nid;
      Break;
    end;
  end;
end;

procedure TfrmPrincipal.sgListaEmpleadosSelectCell(Sender: TObject;
const ACol, ARow: Integer; var CanSelect: Boolean);
var
  I: Integer;
begin
  AsignarValoresCampos(sgListaEmpleados.Cells[1, ARow],
    sgListaEmpleados.Cells[2, ARow], sgListaEmpleados.Cells[3, ARow],
    sgListaEmpleados.Cells[4, ARow], sgListaEmpleados.Cells[5, ARow],
    sgListaEmpleados.Cells[6, ARow], sgListaEmpleados.Cells[0, ARow]);
  CambiarEstadoBotones(EfEditar);
  CanSelect := True;
end;

procedure TfrmPrincipal.AsignarValoresCampos(AIDentificacion, ANombres, AApellidos,
  ACargo, AFechaIngreso, ADependencia, AId: string);
begin
  EdIdentificacion.Text := AIDentificacion;
  EdNombres.Text := ANombres;
  EdApellidos.Text := AApellidos;
  EdCargo.Text := ACargo;
  cbListaDependencia.ItemIndex := ObtenerDependenciaId(ADependencia) - 1;
  deFechaIngreso.Text := AFechaIngreso;
  EdSec.Text := AId;
end;

procedure TfrmPrincipal.BtnAgregarClick(Sender: TObject);
begin
  AsignarValoresCampos(EmptyStr, EmptyStr, EmptyStr, EmptyStr, DateToStr(Date),
    EmptyStr, EmptyStr);
  CambiarEstadoBotones(EfAgregar);
end;

procedure TfrmPrincipal.BtnGuardarClick(Sender: TObject);

begin
  GenerarModeloGuardarEditar(rsrEmpleado, rmPOST);
  ReiniciarProceso;
end;

procedure TfrmPrincipal.Button1Click(Sender: TObject);
var
  Dependencia: string;
begin
  Dependencia := InputBox('Crear dependencia', 'Ingrese dependencia:', '');
  Dependencia := UpperCase(Dependencia);
  GenerarModelGuardarEditarDependencia(rsrDependencia, rmPOST, Dependencia);
end;

procedure TfrmPrincipal.BtnCancelarClick(Sender: TObject);
begin
  ReiniciarProceso;
end;

procedure TfrmPrincipal.BtnEditarClick(Sender: TObject);
begin
  if not AceptaContinuarProceso then
    Exit;
  GenerarModeloGuardarEditar(rsrEmpleado, rmPUT);
end;

procedure TfrmPrincipal.BtnEliminarClick(Sender: TObject);
begin
  if not AceptaContinuarProceso then
    Exit;
  rsrEliminar.ResourceSuffix := 'Empleados/' + EdSec.Text;
  rsrEliminar.Execute;
  ShowMessage(DescomponerResultado(rsEliminar.JSONValue).GetValue<string>);
  CambiarEstadoBotones(EfAgregar);
  LlenarListaEmpleados;
  MessageDlg('¡El registro queda disponible para ser guardado!',
    TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0)
end;

procedure TfrmPrincipal.BtnExportarClick(Sender: TObject);
var
  Listastring: TStringlist;
  Row, Col: Integer;
const
  Ruta = 'D:\Ejercicios\Empleados.csv';
begin
  Listastring := TStringlist.Create;
  try
    for Row := 0 to sgListaEmpleados.RowCount - 1 do
    begin
      var
      InfoRow := '';
      for Col := 0 to sgListaEmpleados.ColumnCount - 1 do
      begin
        InfoRow := InfoRow + '"' + sgListaEmpleados.Cells[Col, Row] + '",';
      end;
      Listastring.Add(InfoRow);
    end;
  finally
    Listastring.SaveToFile(Ruta);
    Listastring.Free;
    ShowMessage('Elementos exportados en la ruta:' + Ruta);
  end;
end;

end.
