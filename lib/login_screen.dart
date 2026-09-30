import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importar el timer

class LoginScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  bool _obscure = true ;


//1.1 crear el cerebro de la animacion
StateMachineController? _controller;
//SMI: State Machine Input
SMIBool? _isChecking;
SMIBool? _isHandsUp;
SMITrigger? _trigSuccess;
SMITrigger? _trigFail;

//3.2 variable del recorrido de la mirada
SMINumber? _numLook;
//3.3 Timer para detener la mirada al dejar de escribir
Timer? _typingDebounce;

//2.1 Crear las variables para FocusNode
final _emailFocus = FocusNode();
final _passwordFocus = FocusNode();
//2.2 Listeners (oyentes/chismosos)
@override
void initState() {
  super.initState();

  _emailFocus.addListener(() {
    if (_emailFocus.hasFocus) {
      // verificar que no sea nulo
      if (_isHandsUp != null) {
        // manos abajo en el email
        _isHandsUp!.change(false);
        //3.4 mirada neutra
        _numLook?.value = 50.0;
      }
    }
  });

  _passwordFocus.addListener(() {
    // manos arriba en el password
    if (_isHandsUp != null) {
      _isHandsUp!.change(_passwordFocus.hasFocus);
    }
  });
}
  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla
    final Size size= MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/logi.riv',
                  stateMachines: ['Login Machine'],
                  //1.2 vincular animacion
                  onInit: (artboard){
                    _controller = StateMachineController. fromArtboard(
                      artboard,
                      'Login Machine',
                      );

                      //1.3 verificar que inicio bien
                      if (_controller==null) return;
                      //Agrega el controlador al escenario/tablero
                      artboard.addController(_controller!);
                      //Vinculamos variables
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      //3.5 vincular la mirada
                      _numLook = _controller!.findSMI('numLook');
                  },
                  ),
              ),
              //para separar espacios
              SizedBox(height: 10),

              //para email
              TextField(
                //2.3 asignar el focusNode al campo de texto
                focusNode: _emailFocus,
                  onChanged: (value){
                  if (_isHandsUp != null){
                   // _isHandsUp!.change(false);
                  }
                  if (_isChecking == null) return;
                  _isChecking!.change(true);
                  //3.6 implementar la mirada
                  //ajuste de limites del 0 a 100
                  //80 es la medida calibracion
                  final look = (value.length /40.0  * 100.0).clamp(0.0, 100.0);
                  //clamp es el rango (abrazadera)
                  _numLook?.value = look;
                  //3.7 Debounce : si vuelve a teclear, reinicia el contador
                  //cancelar cualquier timer existente
                  _typingDebounce?.cancel();
                  //Crear un nuevo timer
                  _typingDebounce = Timer (const Duration(seconds: 3), (){
                    //si se cierra la pantalla, quita el contador
                    if (!mounted) return;
                    //3.8 mirada neutra
                    _isChecking?.change(false);
                  });
                },
                //para mostrar el tipo de teclado
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  )

                ),
              ),
              SizedBox(height: 10),
              //contraeña
              TextField(
                //2.1 asignar el focusNode al campo de texto
                focusNode: _passwordFocus,
                onChanged: (value){
                  if (_isChecking != null){
                  //  _isChecking!.change(false);
                  }
                  if (_isHandsUp == null) return;
                  _isHandsUp!.change(true);
                },
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Contrasena',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        //refrescar el icono
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                      ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )

                ),
              ),
            ],
          ),
          ),
        ),
    );
  }
    @override
    void dispose() {
      //2.4 liberar memoria de los focusNode
      _emailFocus.dispose();
      _passwordFocus.dispose();
      _typingDebounce?.cancel(); //3.9 elimminar el timer
      super.dispose();
  }
}