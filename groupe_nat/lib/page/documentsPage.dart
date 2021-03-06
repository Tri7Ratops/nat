import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupe_nat/model/documentModel.dart';
import 'package:groupe_nat/repository/documentRepository.dart';
import 'package:groupe_nat/routes.dart';
import 'package:groupe_nat/utils/alert.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DocumentsPage extends StatefulWidget {
  static const String routeName = '/documents';

  DocumentsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _loading = true;
  List<DocumentModel> _list = new List<DocumentModel>();

  _getDocuments() async {
    setState(() => _loading = true);
    _list = new List<DocumentModel>();
    var res = await API_DOCUMENTS.getDocuments();

    if (res["message"] != null) {
      MyAlert.basic(context, AlertType.error, "Une erreur est survenue", res["message"]);
    } else {
      for (var item in res["documents"]) {
        _list.add(DocumentModel.fromJson(item));
      }
    }
    _loading = false;
    setState(() {});
  }

  @override
  void initState() {
    _getDocuments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _list.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.document,
                          arguments: DocumentArguments(_list[index]),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(_list[index]
                                .name
                                .substring(0, (_list[index].name.length > 40) ? 40 : _list[index].name.length)),
                            flex: 10,
                          ),
                          Expanded(
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => MyAlert.confirm(context, AlertType.success, "Supression du document",
                                  "Êtes-vous sure de vouloir supprimer le document ?", () async {
                                await API_DOCUMENTS.deleteDocument(_list[index].getId);
                                _getDocuments();
                              }),
                            ),
                            flex: 1,
                          ),
                        ],
                      ),
                    ));
              }),
        ));
  }
}
