import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:daily_sales/services/firestore_service.dart'; // Your FirestoreService
import 'package:daily_sales/utils/utils.dart';
import '../models/produto_table_data.dart';

class ProdutoTablePage extends StatefulWidget {
  const ProdutoTablePage({super.key});

  @override
  _ProdutoTablePageState createState() => _ProdutoTablePageState();
}

class _ProdutoTablePageState extends State<ProdutoTablePage> {
  late ProdutoTableDataSource produtoDataSource;
  String selectedSucursal = 'Total'; // Default selection
  String? selectedCategory; // Selected category for dropdown filter
  List<String> categories = []; // List of categories
  bool isLoadingCategories = true; // To track the loading state of categories

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the widget is initialized
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirestoreService().getProdutoTableData().first;
      setState(() {
        categories = snapshot
            .map((data) => data.categoria ?? 'Unknown')
            .toSet()
            .toList();
        categories.sort();
        isLoadingCategories = false;
      });
    } catch (error) {
      // Handle the error and set loading state to false
      print('Error fetching categories: $error');
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Radio Buttons for filtering by sucursal
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRadioButton('Total'),
            _buildRadioButton('Maputo'),
            _buildRadioButton('Beira'),
            _buildRadioButton('Nampula'),
            _buildRadioButton('Tete'),
            _buildRadioButton('Pemba'),
          ],
        ),
        // Custom Dropdown for filtering by category
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*const Text(
                'Filtrar por Categoria',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),*/
              const SizedBox(height: 2),
              isLoadingCategories
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator
                  : DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text(
                        'Todas categorias',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null, // "All Categories"
                          child: Text(
                            'Todas categorias',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        ...categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ProdutoTableData>>(
            stream: FirestoreService().getProdutoTableData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              // Filter the data based on the selected sucursal and category
              final filteredData = snapshot.data!
                  .where((data) =>
                      data.sucursal == selectedSucursal &&
                      (selectedCategory == null ||
                          data.categoria == selectedCategory))
                  .toList();

              // Assign filtered data to the datasource
              produtoDataSource = ProdutoTableDataSource(filteredData);

              return SfDataGrid(
                key: UniqueKey(),
                headerRowHeight: 40,
                rowHeight: 40,
                source: produtoDataSource,
                gridLinesVisibility: GridLinesVisibility.none,
                allowSorting: true,
                allowMultiColumnSorting: true,
                allowTriStateSorting: true,
                tableSummaryRows: [
                  GridTableSummaryRow(
                    showSummaryInRow: false,
                    color: Colors.deepPurple.shade50,
                    title: 'No. de produtos: {descricao}',
                    titleColumnSpan: 1,
                    columns: [
                      const GridSummaryColumn(
                        name: 'descricao',
                        columnName: 'descricao',
                        summaryType: GridSummaryType.count,
                      ),
                      const GridSummaryColumn(
                        name: 'stock',
                        columnName: 'stock',
                        summaryType: GridSummaryType.sum,
                      ),
                      const GridSummaryColumn(
                        name: 'qtd',
                        columnName: 'qtd',
                        summaryType: GridSummaryType.sum,
                      ),
                      const GridSummaryColumn(
                        name: 'valor',
                        columnName: 'valor',
                        summaryType: GridSummaryType.sum,
                      ),
                    ],
                    position: GridTableSummaryRowPosition.bottom,
                  ),
                ],
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'descricao',
                    allowSorting: false,
                    label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                      ),
                      child: const Text(
                        'Descricao',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  GridColumn(
                    maximumWidth: 100,
                    columnName: 'stock',
                    label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                      ),
                      child: const Text(
                        'Stock',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  GridColumn(
                    maximumWidth: 100,
                    columnName: 'qtd',
                    label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                      ),
                      child: const Text(
                        'Qtd',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  GridColumn(
                    maximumWidth: 100,
                    columnName: 'valor',
                    label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                      ),
                      child: const Text(
                        'Valor',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
                columnWidthMode: ColumnWidthMode.fill,
                allowColumnsResizing: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedSucursal,
          onChanged: (String? newValue) {
            setState(() {
              selectedSucursal = newValue!;
            });
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class ProdutoTableDataSource extends DataGridSource {
  List<DataGridRow> _produtoDataGridRows = [];

  ProdutoTableDataSource(List<ProdutoTableData> produtoData) {
    produtoData.sort((a, b) => b.valor.compareTo(a.valor));

    _produtoDataGridRows = produtoData
        .map<DataGridRow>((data) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'descricao', value: data.descricao),
              DataGridCell<double>(columnName: 'stock', value: data.stock),
              DataGridCell<double>(columnName: 'qtd', value: data.qtd),
              DataGridCell<double>(columnName: 'valor', value: data.valor),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _produtoDataGridRows;

  /*@override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        summaryValue,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }*/

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    // Format the sum values for 'stock', 'qtd', and 'valor'
    if (summaryColumn != null) {
      if (summaryColumn.name == 'stock' ||
          summaryColumn.name == 'qtd' ||
          summaryColumn.name == 'valor') {
        double sumValue = double.tryParse(summaryValue) ?? 0.0;

        // Apply formatting (e.g., add commas and 2 decimal places)
        summaryValue = Utils.formatNumberWithCommas(sumValue.toInt());
      }
    }

    // Check if the title property of the GridTableSummaryRow contains 'descricao'
    //Alignment alignment = Alignment.center; // Default to center
    //if (summaryRow.title?.contains('{descricao}') ?? false) {
      //alignment = Alignment.centerLeft; // Align left if 'descricao' is in the title
    //}


    // Check if the summary is for the 'descricao' column
    /*Alignment alignment = Alignment.center; // Default to center
    if (summaryColumn != null && summaryColumn.name == 'descricao') {
      alignment = Alignment.centerLeft; // Align left for 'descricao'
    }*/

    return Container(
      padding: const EdgeInsets.all(10.0),
      alignment: Alignment.center, // Align to the right for numeric values
      child: Text(
        summaryValue,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }


  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rowIndex = _produtoDataGridRows.indexOf(row);

    return DataGridRowAdapter(
      color: Utils.alternateTableLineColors(
          rowIndex), // Set the alternating background color
      cells: [
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            row.getCells()[0].value!,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            Utils.formatNumberWithCommas(row.getCells()[1].value!.toInt()),
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            Utils.formatNumberWithCommas(row.getCells()[2].value!.toInt()),
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            Utils.formatNumberWithCommas(row.getCells()[3].value!.toInt()),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
