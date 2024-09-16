class ProdutoTableData {
  ProdutoTableData(this.sucursal, this.principal, this.categoria,
      this.descricao, this.qtd, this.valor,this.stock); // Valor
//final String date;      // Data with hours and minutes
  final String sucursal;
  final String principal;
  final String categoria;
  final String descricao;   // Descricao
  final double qtd;         // Qtd
  final double valor;
  final double stock;
}