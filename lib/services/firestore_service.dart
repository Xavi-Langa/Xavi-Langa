import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_sales/models/sucursal_chart_data.dart'; // Import ChartData model
import 'package:daily_sales/models/principal_table_data.dart';
import 'package:daily_sales/utils/utils.dart';
import '../models/produto_table_data.dart'; // Import utils

class FirestoreService {
  Stream<DocumentSnapshot> getLastUpdateStream() {
    return FirebaseFirestore.instance
        .collection('Vendas')
        .doc('last_update')
        .snapshots();
  }

  Stream<Map<String, dynamic>> getSucursalChartData() {
    final currentMonth = Utils.getCurrentMonth();

    return FirebaseFirestore.instance
        .collection('Vendas')
        .doc(currentMonth)
        .collection('Valor')
        .snapshots()
        .map((snapshot) {
      double totalValue = 0.0;
      double totalValueToday = 0.0;
      String? date;
      List<SucursalChartData> sucursalData = [];

      for (var doc in snapshot.docs) {
        final nivel = doc['nivel'] as String;
        final valor = (doc['valor'] as num).toDouble();
        final percentual = (doc['percentual'] as num).toDouble();
        final valor_do_dia = (doc['valor_do_dia'] as num).toDouble();

        if (nivel == 'Sucursal') {
          sucursalData.add(SucursalChartData(
            doc['descricao'],
            //Utils.roundToDecimal(valor / 1000000, 1),
            valor,
            Utils.roundToDecimal(percentual, 0),
            Utils.formatDateTime((doc['data'] as Timestamp).toDate()),
            Utils.roundToDecimal(valor_do_dia, 0),
          ));
        } else if (nivel == 'Total') {
          totalValue = valor;
          totalValueToday = valor_do_dia;
          if (doc['data'] != null) {
            DateTime dateTime = (doc['data'] as Timestamp).toDate();
            date = Utils.formatDateTime(dateTime);
          }
        }
      }

      sucursalData.sort((a, b) {
        List<String> order = ['Maputo', 'Beira', 'Tete', 'Nampula', 'Pemba'];
        return order.indexOf(a.sucursal).compareTo(order.indexOf(b.sucursal));
      });

      return {
        'sucursalData': sucursalData,
        'totalValue': Utils.roundToDecimal(totalValue / 1000000, 1),
        'totalValueToday': Utils.formatNumberWithCommas(totalValueToday.toInt()),
        'date': date,
      };
    });
  }

  // New method to get documents where "nivel = Principal"
  Stream<List<PrincipalTableData>> getPrincipalTableData() {
    final currentMonth = Utils.getCurrentMonth();

    return FirebaseFirestore.instance
        .collection('Vendas')
        .doc(currentMonth)
        .collection('Valor')
        .where('nivel', isEqualTo: 'Principal')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final descricao = doc['descricao'] as String;
        final valor = (doc['valor'] as num).toDouble();
        final tons = (doc['tons'] as num).toDouble();
        final percentual = (doc['percentual'] as num).toDouble();

        return PrincipalTableData(descricao, valor, percentual, tons);
      }).toList();
    });
  }

  // New method to get documents where "nivel = Produto"
  Stream<List<ProdutoTableData>> getProdutoTableData() {
    final currentMonth = Utils.getCurrentMonth();

    return FirebaseFirestore.instance
        .collection('Vendas')
        .doc(currentMonth)
        .collection('Qtd')
        //.where('sucursal', isEqualTo: 'Total')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final sucursal = doc['sucursal'] as String;
        final principal = doc['principal'] as String;
        final categoria = doc['categoria'] as String;
        final descricao = doc['descricao'] as String;
        final qtd = (doc['qtd'] as num).toDouble();
        final valor = (doc['valor'] as num).toDouble();
        final stock = (doc['stock'] as num).toDouble();

        return ProdutoTableData(
            sucursal, principal, categoria, descricao, qtd, valor, stock);
      }).toList();
    });
  }
}
