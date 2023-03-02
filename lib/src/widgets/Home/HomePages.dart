import 'package:crud_sqlite_flutter/src/BD/db_helper.dart';
import 'package:flutter/material.dart';

class HomePages extends StatefulWidget {
  const HomePages({Key? key}) : super(key: key);

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  List<Map<String,dynamic>> _allData = [];

  bool _isLoading = true;
// maostrando todos los datos de la Base de Datos
  void _refreshData()async{
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;

    });

  }

  @override
  void initState(){
    super.initState();
    _refreshData();
  }
  //Agregar Datos
Future<void> _addData() async{
  await SQLHelper.createData(_titleController.text, _descController.text);
  _refreshData();
}
//Acttualizar Datos
Future<void>_updateData(int id)async{
  await SQLHelper.updateData(id, _titleController.text, _descController.text);
  _refreshData();
}
// Eliminar Datos
void _deleteData(int id)async{
  await SQLHelper.deleteData(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    backgroundColor: Colors.redAccent,
    content:Text("Elemento Eliminado"),
  ));
  _refreshData();

}
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();


  void showButtomSheet(int? id)async{
    if(id!=null){
      final existingData = _allData.firstWhere((element) => element["id"]==id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
    elevation: 5,
        isScrollControlled: true,
        context: context, builder: (_)=>Container(
        padding: EdgeInsets.only(
          top: 20,
          right: 15,
          left: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Title"
            ),
          ),
          const SizedBox(height: 30,),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),

                hintText: "Description"
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async{
                if(id == null){
                  await _addData();
                }
                if(id != null){
                  await _updateData(id);
                }
                _titleController.text ="";
                _descController.text = "";
                
               //ocultando el Boton 
                Navigator.of(context).pop();
                print("Dato Agregado");
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  id == null ?"Add Data":"Update",
                  style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500,),
                ),
              ),
            ),
          )
        ],
      ),

    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text("CRUD "),
    ),
      body: _isLoading ? const Center(
    child: CircularProgressIndicator(),
    )
        : ListView.builder(
        itemCount: _allData.length,
          itemBuilder:(context,index)=>Card(
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _allData[index]['title'],
                  style: const TextStyle(
                      fontSize: 20,
                  ),
                ),
              ),
              subtitle:  Text(_allData[index]['desc']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: (){
                    showButtomSheet(_allData[index]['id']);
                  },
                      icon: const Icon(Icons.edit,
                        color: Colors.indigo,
                      ),
                  ),
                  IconButton(onPressed: (){
                    _deleteData(_allData[index]['id']);
                  },
                    icon: const Icon(Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ) ,
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> showButtomSheet(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
