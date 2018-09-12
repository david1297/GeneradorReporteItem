unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.DateTimeCtrls, FMX.Layouts, FMX.ListBox, FMX.Edit,
  FMX.Controls.Presentation, FMX.SearchBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Edit1: TEdit;
    AddItem: TButton;
    ListBox1: TListBox;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Label1: TLabel;
    Label2: TLabel;
    Generar: TButton;
    Conexion: TFDConnection;
    Qconsulta: TFDQuery;
    procedure AddItemClick(Sender: TObject);
    procedure GenerarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.AddItemClick(Sender: TObject);
begin
  if Edit1.Text <> '' then
  BEGIN
    ListBox1.Items.Add(Edit1.Text);
  END;

end;

procedure TForm1.GenerarClick(Sender: TObject);
begin
  Qconsulta.SQL.Add
    ('SELECT NUMERO,TIPO,ID_EMPRESA,ID_SUCURSAL,ID_CLIENTE,TOTAL,SUBTOTAL,FORMA_PAGO,SU_SOLICITUD,'
    + ' DP,CC,MEDIO_ENTREGA,MONEDA_COTI,VENDEDOR,TIPO_CAMB_HOY,TIPO_CLIENTE,MEDIO_CONTACTO,'
    + ' CONTACTO,EN_PEDIDO_NO,CIUDAD_PAIS,OBSERVACIONES,DCTO_ADC_P,DCTO_ADC_VALOR,COMENTARIO,ESTADO_N,'
    + ' MOTIVO_APLAZ,FECHA,FECHA_VEN,FECHA_ENTREGA,PROX_LLAMADA,TOTALDESCTO,TOTALIVA,ANULAR,PROYECTO,'
    + ' ID_USUARIO,coalesce(AUTORIZADO,''N'')AUTORIZADO,SHIPTO,COD_NIVEL,COD_MONEDA,TRM,TOTAL_MEXT,'
    + ' FECHA_TRM,IDN_CONTADO,LETRASING,IVA_FACTURA,CONCEPTOSIVA,SUB_FACTURA,TOT_FACTURA,'
    + ' DESC_FACTURA,LISTA_COTIZA,VALIDEZ,ESTADO,BONOTOTAL,NOMBRECOT' +
    ' from COTIZACI  WHERE FECHA BETWEEN :FI AND :FF');
    Qconsulta
  Qconsulta.ParamByName('FI').AsDate := DateEdit1.Date;
  QCotizaci.ParamByName('FF').AsDate := DateEdit2.Date;
  QCotizaci.SQL.Add(' AND TIPO IN(' + Tipos + ')');
end;

end.