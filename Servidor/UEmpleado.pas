unit UEmpleado;

interface

type
  TEmpleado = class
    fun_nid: Integer;
    fun_cidentificacion: string;
    fun_cnombres: string;
    fun_capellidos: string;
    fun_cargo: string;
    fun_dep_nid: Integer;
    fun_fecha_ingreso: string;
  end;

type
  TDependencia = class
  public
    dep_nid: Integer;
    dep_nombredependencia: string;
    constructor Create(AId: Integer; ANombre: String);
  end;

type
  TEmpleadosDependencia = class(TEmpleado)
    dep_nombredependencia: string;
  end;

implementation

constructor TDependencia.Create(AId: Integer; ANombre: String);
begin
  dep_nid := AId;
  dep_nombredependencia := ANombre;
end;

end.
