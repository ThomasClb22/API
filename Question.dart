import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

import 'constant.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PageDev(),
    );
  }
}

class PageDev extends StatefulWidget {
  const PageDev({super.key});

  @override
  State<PageDev> createState() => _PageDevState();
}

// _____ DEBUT ERREUR ______

Future<String> generateResponse(String prompt) async {
  const apiKey = apiSecretKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0.9,
      'max_tokens': 1000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
      "stop": ["You: "]
    }),
  );

  // Do something with the response
  Map<String, dynamic> newresponse = jsonDecode(response.body);

  return newresponse['choices'][0]['text'];
}

// _____ FIN ERREUR ______

class _PageDevState extends State<PageDev> {
  String messageIaPdf = "";

  final _textController = TextEditingController();
  late bool isLoading;

  final _formKey = GlobalKey<FormState>();

  void clearTextInfos() {
    _textController.clear();
  }

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {

    var textPreFinal = _textController.text;

    var messFinal = '$textPreFinal';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 135, 184, 228),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30) 
          )
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    height: 2,
                    width: 150,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 135, 184, 228),
                    ), 
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Posez une question', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                cursorColor: Color.fromARGB(255, 135, 184, 228),
                                textCapitalization: TextCapitalization.sentences,
                                maxLines: 5,
                                style: const TextStyle(color: Colors.black),
                                controller: _textController,
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(color: Color.fromARGB(255, 135, 184, 228), width: 2.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.abc, color: Colors.grey),
                                  labelStyle: TextStyle(color: Colors.grey)
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Champ requis';
                                  }
                                  return null;
                                }
                              ),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Visibility(
                    visible: isLoading,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      runSpacing: 20,
                      children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white
                        ),
                        onPressed: (() {
                          clearTextInfos();
                        }),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Effacer"),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 135, 184, 228),
                          foregroundColor: Colors.white
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Envoyer"),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            String response = await generateResponse(messFinal);
                            setState(() {
                              messageIaPdf = response;
                              isLoading = false;
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Réponse"),
                                  content: SingleChildScrollView(
                                    child:Text(response)
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
