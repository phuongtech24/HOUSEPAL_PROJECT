import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final DeleteExpense deleteExpense;

  ExpensesBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.deleteExpense,
  }) : super(ExpensesInitial()) {
    on<LoadExpenses>((event, emit) async {
      emit(ExpensesLoading());
      try {
        final items = await getExpenses();
        emit(ExpensesLoaded(items));
      } catch (e) {
        emit(ExpensesError('Không thể tải dữ liệu: ${e.toString()}'));
      }
    });

    on<AddExpenseEvent>((event, emit) async {
      try {
        await addExpense(event.expense);
        add(LoadExpenses());
      } catch (e) {
        emit(ExpensesError('Không thể thêm: ${e.toString()}'));
      }
    });

    on<DeleteExpenseEvent>((event, emit) async {
      try {
        await deleteExpense(event.id);
        add(LoadExpenses());
      } catch (e) {
        emit(ExpensesError('Không thể xóa: ${e.toString()}'));
      }
    });
  }
}
