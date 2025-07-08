import '../logger.dart';
import '../ui.dart';


String getUserId(){
  return globalBoxStorage.read('user_id');
}


