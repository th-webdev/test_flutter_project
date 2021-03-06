import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_flutter_project/bloc/guide_bloc.dart';
import 'package:test_flutter_project/models/guide.dart';
import 'package:test_flutter_project/one_guide.dart';

class GuideList extends StatefulWidget {
  @override
  _GuideListState createState() => _GuideListState();
}

class _GuideListState extends State<GuideList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuideBloc, GuideState>(
      builder: (context, state) {
        switch (state.status) {
          case GuideStatus.error:
            return const Center(child: Text('failed to get guides'));
          case GuideStatus.success:
            if (state.guides.isEmpty) {
              return const Center(child: Text('no guides'));
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.guides.length
                    ? _loader()
                    : _listItem(state.guides[index]);
              },
              itemCount: state.allDataReceived
                  ? state.guides.length
                  : state.guides.length + 1,
              controller: _scrollController,
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _loader(){
    return Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }

  _listItem(Guide guide){
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OneGuide(guide)));
      },
      child: Column(
        children: [
          Container(
            child: Image.network(
              '${guide.icon}',
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            child: Text('${guide.name}', textAlign: TextAlign.center, style: TextStyle(
                color: Colors.white
            ),),),
          Text('${guide.endDate}', style: TextStyle(
              color: Colors.white60
          )),
          SizedBox(height: 80,)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<GuideBloc>().add(GuideLoader());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 1);
  }
}