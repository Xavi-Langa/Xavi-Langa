class SucursalChartData {
  SucursalChartData(this.sucursal, this.valor, this.percentual, this.date, this.valor_do_dia);
  final String sucursal;         // Descricao
  final double valor;         // Valor
  final double valor_do_dia;
  final double percentual; // Percentual
  final String date;      // Data with hours and minutes
}
