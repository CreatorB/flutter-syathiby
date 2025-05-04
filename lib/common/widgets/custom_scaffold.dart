import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final Widget? trailing;
  final Color? navigationBarBackgroundColor;
  final bool automaticallyImplyLeading;
  final EdgeInsetsDirectional? navigationBarPadding;
  final ScrollController? scrollController;

  const CustomScaffold({
    super.key,
    required this.title,
    required this.children,
    this.onRefresh,
    this.trailing,
    this.navigationBarBackgroundColor = Colors.transparent,
    this.automaticallyImplyLeading = true,
    this.navigationBarPadding,
    this.scrollController,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  late final ScrollController _effectiveScrollController;
  
  @override
  void initState() {
    super.initState();
    _effectiveScrollController = widget.scrollController ?? ScrollController();
  }
  
  @override
  void dispose() {
    if (widget.scrollController == null) {
      _effectiveScrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              padding: widget.navigationBarPadding,
              backgroundColor: widget.navigationBarBackgroundColor,
              border: null,
              middle: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ).tr(),
              brightness: themeState.isDark ? Brightness.dark : Brightness.light,
              trailing: widget.trailing,
              automaticallyImplyLeading: widget.automaticallyImplyLeading,
            ),
            child: SafeArea(
              bottom: true,
              child: widget.onRefresh != null 
                ? _buildWithRefresh(context)
                : _buildWithoutRefresh(context),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildWithRefresh(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh!,
      child: _buildScrollView(context),
    );
  }
  
  Widget _buildWithoutRefresh(BuildContext context) {
    return _buildScrollView(context);
  }
  
  Widget _buildScrollView(BuildContext context) {
    return SingleChildScrollView(
      controller: _effectiveScrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add extra padding at the top for better scrolling
            const SizedBox(height: 8),
            
            // Main content
            ...widget.children,
            
            // Add extra padding at the bottom for better scrolling
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}