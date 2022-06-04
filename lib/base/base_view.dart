import 'package:flutter/material.dart';

class BaseView<T> extends StatefulWidget {
      final Widget Function(BuildContext c, T value) pageBuilder;
      final T viewModel;
      final Function(T model) onModelReady;
      final VoidCallback onDispose;
      const BaseView(
      {Key key,
           this.viewModel,
           this.onModelReady,
           this.onDispose,
           this.pageBuilder})
           : super(key: key);
      @override
      _BaseViewState createState() => new _BaseViewState();
      }
class _BaseViewState extends State<BaseView> {
   @override
   void initState() {
   super.initState();
   if (widget.onModelReady != null) widget.onModelReady(widget.viewModel);
   }
   @override
   void dispose() {
   super.dispose();
   if (widget.onDispose != null) widget.onDispose();
   }
   @override
   Widget build(BuildContext context) {
   return widget.pageBuilder(context, widget.viewModel);
   }
}