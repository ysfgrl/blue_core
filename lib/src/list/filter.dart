
part of 'blue_list.dart';

class _BlueListFilter<LType extends BaseModel> extends StatelessWidget{

  final ListBloc<LType> listBloc;
  final FilterBuilder<LType> filterBuilder;
  const _BlueListFilter({
    super.key,
    required this.listBloc,
    required this.filterBuilder,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListBloc<LType>, ListState<LType>>(
      bloc: listBloc,
      builder: (context, state) {
        return filterBuilder(context, state.filters);
      },
      buildWhen: (previous, current) => true,
    );
  }
}