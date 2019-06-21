import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _scrollController = new ScrollController();
  String displayValue='';


  void updateDisplay(String newVal){
    UserInput currInput=new UserInput(newVal, displayValue);
    currInput.checkInput();
    displayValue=currInput.completeLine;
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    Row displayAnswer=Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
        child: Container(

          margin: EdgeInsets.all(10),
          height: 80,
      child:ListView(
        reverse: true,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Text(
            displayValue,style: TextStyle(fontSize: 60),
          ),


        ],

      )
        )
        )
      ],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),centerTitle: true,
      ),
      body: Center(

        child: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: displayAnswer,
            ),
            Expanded(
              flex: 1,
              child: Container( color: Colors.black, child:Row()),
            ),
            Expanded(
              flex: 3,
              child: Container( color: Colors.black, child:CreateRows().setRows(context, '(', ')', 'Back','/',updateDisplay)),
            ),
            Expanded(
                flex: 3,
                child:Container( color: Colors.black, child: CreateRows().setRows(context, '7', '8', '9','x',updateDisplay)),
            ),
            Expanded(
                flex: 3,
                child: Container( color: Colors.black, child:CreateRows().setRows(context, '4', '5', '6','-',updateDisplay)),
            ),
            Expanded(
                flex: 3,
                child: Container( color: Colors.black, child:CreateRows().setRows(context, '1', '2', '3','+',updateDisplay)),
            ),
            Expanded(
              flex: 3,
              child: Container( color: Colors.black, child:CreateRows().setRows(context, 'Clear', '0', '.','=',updateDisplay)),
            )


          ],
        ),
      ),
    );
  }
}

class CreateButtons{
  setButton(context,String input,Function buttonPressAction){
    var foundColor;
    if(input=='='){
      foundColor=Colors.red;
    }
    else if(input=='/'||input=='x'||input=='-'||input=='+'||input=='Back'||input=='('||input==')'){
      foundColor=Colors.grey;
    }
    else{
      foundColor=Colors.white;
    }
    return MaterialButton(onPressed:(){
      buttonPressAction(input);
    }, child: Text(input,style: TextStyle(color: Colors.black,fontSize: 22),),color:foundColor,
      height: 84,
      minWidth: 85,
    );
  }
}
class CreateRows{
  setRows(context,String display1,String display2,String display3,display4,Function buttonPressAction){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CreateButtons().setButton(context, display1,buttonPressAction),
        CreateButtons().setButton(context, display2,buttonPressAction),
        CreateButtons().setButton(context, display3,buttonPressAction),
        CreateButtons().setButton(context, display4,buttonPressAction),
      ],
    );

  }
}

class UserInput{
  Queue values=new Queue();
  Queue ops=new Queue();
  String inputVal;
  String completeLine;
  int i=0;
  UserInput(this.inputVal,this.completeLine);

  checkInput(){
    if(inputVal=='='){
      calculateExpression();
    }
    else if(inputVal=='/'||inputVal=='x'||inputVal=='-'||inputVal=='+'){
      if(completeLine.length<25) {
        inputOperator(inputVal);
      }
    }
    else if(inputVal=='Clear'){
      completeLine='';
    }
    else if(inputVal=='Back'){
      if(completeLine.length>0){
        completeLine=completeLine.substring(0,completeLine.length-1);
      }

    }
    else{
      if(completeLine.length<25){
        completeLine+=inputVal;
      }

    }
  }
  bool checkParenthesisBalance(){
    int balanced=0;
    bool numFound=false;
    for(int j=0;j<completeLine.length;j++){
      if(completeLine[j]=='(')
        balanced++;
      else if(completeLine[j]==')')
        balanced--;
      else
        numFound=true;
    }
    if(numFound==false)
      return false;
    int temp=i;
    i=completeLine.length-1;
    if(completeLine[completeLine.length-1]=='('||(!(isDigit(completeLine))&&completeLine[completeLine.length-1]!=')'))
      return false;
    i=temp;
    if(balanced==0)
      return true;
    return false;
  }
  putOpenParenthesis(){
    ops.addLast(completeLine[i]);
  }
  isADecimalNumber(){
   if( isDigit(completeLine) || completeLine[i] == '.' || ((completeLine[i] == '-') && (i == 0 ? true : (completeLine[i - 1] == '(' || completeLine[i - 1] == 'x' || completeLine[i - 1] == '/' || completeLine[i - 1] == '-' || completeLine[i - 1] == '+'))))
     return true;
   return false;
  }

  addNumberToQueue(){
    double val = 0;
    String fullNum = '';
    do {
      fullNum += completeLine[i];
      i++;
    }
    while (i < completeLine.length && (isDigit(completeLine) || completeLine[i] == '.'));
    val = double.parse(fullNum);
    i--;
    values.addLast(val);
  }
  insideParenthesisCalculations(){
    while (ops.isNotEmpty && ops.last != '(') {
      performOperations();
    }
    ops.removeLast();
  }
  operationsFinishedAndNewOneAdded(){
    while (ops.isNotEmpty && precedence(ops.last) >= precedence(completeLine[i])) {
      performOperations();
    }

    ops.addLast(completeLine[i]);
  }
  completeCalculation(var values, var ops){
    for(i=0;i<completeLine.length;i++) {
      if (completeLine[i] == '(') {
        putOpenParenthesis();
      }
      else if (isADecimalNumber()) {
        addNumberToQueue();
      }
      else if (completeLine[i] == ')') {
        insideParenthesisCalculations();
      }
      else {
        operationsFinishedAndNewOneAdded();
      }
    }
  }
  performOperations(){
    double val2=values.last;
    values.removeLast();

    double val1=values.last;
    values.removeLast();

    var op=ops.last;
    ops.removeLast();

    values.addLast(applyOp(val1,val2,op));
  }
  bool checkIfFinalValueIsDecimal(){
    var checkWholeNumber=values.last.toString();
    bool afterDecimal=false;
    bool isDecimalNumber=false;
    for(int j=0;j<checkWholeNumber.length;j++){
      if(afterDecimal==true&&checkWholeNumber[j]!='0'){
        isDecimalNumber=true;
      }
      if(checkWholeNumber[j]=='.'){
        afterDecimal=true;
      }
    }
    if(isDecimalNumber)
      return true;
    return false;
  }
  generateFinalValue(){
    if(checkIfFinalValueIsDecimal()){

      completeLine=values.last.toStringAsFixed(3);
      if(completeLine[completeLine.length-1]=='0'){
        completeLine=completeLine.substring(0,completeLine.length-1);
      }
    }
    else{
      completeLine=values.last.round().toString();
    }
  }
  calculateExpression(){
    if(checkParenthesisBalance()){
      completeCalculation(values,ops);
      while(ops.isNotEmpty){
        performOperations();
      }
      generateFinalValue();
    }
  }

  bool isDigit(String s)=>(s.codeUnitAt(i)^0x30)<=9;

  int precedence(var op){
    if(op=='+'||op=='-')
      return 1;
    if(op=='x'||op=='/')
      return 2;
    return 0;
  }

  double applyOp(double a,double b, var op){
    switch(op){
      case '+':
        return a+b;
      case '-':
        return a-b;
      case 'x':
        debugPrint('${a*b}');
        return a*b;
      case '/':
        return a/b;
      default:
        return 0;
    }
  }
  inputOperator(String newVal){
    if(completeLine.length==0){
      if(newVal=='-'){
        completeLine+=newVal;
      }
    }
    else if(completeLine[completeLine.length-1]!=newVal){
      if(completeLine[completeLine.length-1]=='/'||completeLine[completeLine.length-1]=='x'||completeLine[completeLine.length-1]=='-'||completeLine[completeLine.length-1]=='+'){
        if(newVal=='-'){
          completeLine=completeLine+newVal;
        }
        else{
          completeLine=completeLine.substring(0,completeLine.length-1)+newVal;
        }
      }
      else{
        completeLine=completeLine+newVal;
      }
    }
  }
}
