import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:provider/provider.dart';
import '../models/sheet_model.dart';

class AddSheetScreen extends StatefulWidget {
  final Sheet item;

  const AddSheetScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddSheetScreenState();
}

class _AddSheetScreenState extends State<AddSheetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Sheet _item = widget.item;
    return Consumer<SheetModel>(
      builder: (context, sm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_item.id.isNotEmpty ? "Editar Ficha" : "Nova Ficha"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  constraints:
                      const BoxConstraints(minWidth: 100, maxWidth: 600),
                  child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: 'Nome do personagem',
                                    ),
                                    initialValue: widget.item.name,
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Insira o nome do personagem';
                                      }
                                      return null;
                                    },
                                    onChanged: (String? val) {
                                      setState(() {
                                        widget.item.name = val ?? "";
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: TextFormField(
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Raça',
                                      ),
                                      initialValue: widget.item.race,
                                      // validator: (String? value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return 'Insira a raça do personagem';
                                      //   }
                                      //   return null;
                                      // },
                                      onChanged: (value) {
                                        setState(() {
                                          widget.item.race = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: TextFormField(
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Classe',
                                      ),
                                      initialValue: widget.item.classEspec,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.item.classEspec = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: 'Nível',
                                      ),
                                      initialValue: widget.item.level,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.item.level = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    maxWidth: 600,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          sm.add(widget.item);
                          // Navigator.pop(context);
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName("/"),
                          );
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.save), Text('Salvar')],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
