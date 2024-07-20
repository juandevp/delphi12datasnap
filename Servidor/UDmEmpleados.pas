unit UDmEmpleados;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, UEmpleado, System.Generics.Collections, System.JSON,
  REST.JSON, FireDAC.Stan.StorageJSON;

type
  TDmEmpleados = class(TDataModule)
    connDB: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    qInsertarEmpleados: TFDQuery;
    qConsultarDependencias: TFDQuery;
    qListaEmpleados: TFDQuery;
    qActualizarEmpleado: TFDQuery;
    qEliminarEmpleado: TFDQuery;
    qInsertarDependencia: TFDQuery;
  private
    { Private declarations }

  public
    procedure GuardarEmpleados(AEmpleado: TEmpleado);
    function ObtenerDependencias: TObjectList<TDependencia>;
    function ObtenerListaEmpleados: TJSONArray;
    procedure ActualizarInfoEmpleado(AEmpleado: TEmpleado);
    function EliminarEmpleado(AId: Integer): Integer;
    procedure CrearDependencia(ADependencia: TDependencia);
    { Public declarations }
  end;

var
  DmEmpleados: TDmEmpleados;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDmEmpleados.CrearDependencia(ADependencia: TDependencia);
begin
  qInsertarDependencia.ParamByName('dep_nombredependencia').AsString :=
    ADependencia.dep_nombredependencia;
  qInsertarDependencia.ExecSQL;
end;

function TDmEmpleados.EliminarEmpleado(AId: Integer): Integer;
begin
  qEliminarEmpleado.ParamByName('fun_nid').AsInteger := AId;
  qEliminarEmpleado.ExecSQL;

  Result := qEliminarEmpleado.RowsAffected;
end;

function TDmEmpleados.ObtenerListaEmpleados: TJSONArray;
var
  I: TField;
begin
  connDB.Connected := True;
  qListaEmpleados.Open;
  Result := TJSONArray.Create;
  try
    while not qListaEmpleados.Eof do
    begin
      var
      JSonValue := TJSONObject.Create;
      for I in qListaEmpleados.Fields do
      begin
        JSonValue.AddPair(I.FullName, I.AsString);
      end;
      Result.AddElement(JSonValue);
      qListaEmpleados.Next;
    end;
  finally
    qListaEmpleados.Close;
    connDB.Connected := False;
  end;
end;

function TDmEmpleados.ObtenerDependencias: TObjectList<TDependencia>;
var
  dependencias: TObjectList<TDependencia>;
begin
  connDB.Connected := True;
  dependencias := TObjectList<TDependencia>.Create;
  try
    qConsultarDependencias.Open;
    while not qConsultarDependencias.Eof do
    begin
      dependencias.Add(TDependencia.Create(qConsultarDependencias.FieldByName
        ('dep_nid').AsInteger, qConsultarDependencias.FieldByName
        ('dep_nombredependencia').AsString));
      qConsultarDependencias.Next;
    end;
    Result := dependencias;
  finally
    qConsultarDependencias.Close;
    connDB.Connected := False;
  end;
end;

procedure TDmEmpleados.GuardarEmpleados(AEmpleado: TEmpleado);
begin
  connDB.Connected := True;
  try
    qInsertarEmpleados.ParamByName('fun_cidentificacion').AsString :=
      AEmpleado.fun_cidentificacion;
    qInsertarEmpleados.ParamByName('fun_cnombres').AsString :=
      AEmpleado.fun_cnombres;
    qInsertarEmpleados.ParamByName('fun_capellidos').AsString :=
      AEmpleado.fun_capellidos;
    qInsertarEmpleados.ParamByName('fun_cargo').AsString := AEmpleado.fun_cargo;
    qInsertarEmpleados.ParamByName('fun_dep_nid').AsInteger :=
      AEmpleado.fun_dep_nid;
    qInsertarEmpleados.ParamByName('fun_fecha_ingreso').AsDate :=
      StrToDate(AEmpleado.fun_fecha_ingreso);
    qInsertarEmpleados.ExecSQL;
  finally
    connDB.Connected := False;
  end;
end;

procedure TDmEmpleados.ActualizarInfoEmpleado(AEmpleado: TEmpleado);
begin
  connDB.Connected := True;
  try
    qActualizarEmpleado.ParamByName('fun_cidentificacion').AsString :=
      AEmpleado.fun_cidentificacion;
    qActualizarEmpleado.ParamByName('fun_cnombres').AsString :=
      AEmpleado.fun_cnombres;
    qActualizarEmpleado.ParamByName('fun_capellidos').AsString :=
      AEmpleado.fun_capellidos;
    qActualizarEmpleado.ParamByName('fun_cargo').AsString :=
      AEmpleado.fun_cargo;
    qActualizarEmpleado.ParamByName('fun_dep_nid').AsInteger :=
      AEmpleado.fun_dep_nid;
    qActualizarEmpleado.ParamByName('fun_nid').AsInteger := AEmpleado.fun_nid;

    qActualizarEmpleado.ExecSQL;
  finally
    connDB.Connected := False;
  end;
end;

end.
