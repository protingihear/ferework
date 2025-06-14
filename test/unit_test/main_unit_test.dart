import 'api_service/createCategory.dart' as createCategory;
import 'api_service/createPost.dart' as createPost;
import 'api_service/getCategory.dart' as getCategory;
import 'auth_service/login_test.dart' as login;
import 'api_service/getUserProfile.dart' as getUserProfile;
import 'api_service/uploadBerita.dart' as uploadBerita;
import 'api_service/getBerita.dart' as getBerita;
import 'api_service/createSubCategory.dart' as  createSubCategory;
import 'api_service/getCommunities.dart' as getCommunities;
import 'api_service/getPosts.dart' as getPosts;
import 'api_service/getCommunityPost.dart' as getCommunityPost;
import 'api_service/getMyPost.dart' as getMyPost;
import 'api_service/createReplyPost.dart' as createReplyPost;
import 'api_service/updateProfile.dart' as updateProfile;
import 'auth_service/logout_test.dart' as logout;
import "api_service/updateCommunity.dart" as updateCommunity;
import 'api_service/updateRole.dart' as updateRole;
import 'api_service/createCommunity.dart' as createCommunity;

void main() {
  getCategory.main(); //2
  getUserProfile.main(); //3
  createCommunity.main(); //4
  uploadBerita.main(); //5
  getBerita.main(); //6
  updateProfile.main(); //7
  updateCommunity.main(); //8
  createCategory.main(); //9
  createSubCategory.main(); //10
  getCommunities.main(); //11
  getPosts.main(); //12
  updateRole.main(); //13
  createPost.main(); //14
  getCommunityPost.main(); //15
  getMyPost.main(); //16
  createReplyPost.main(); //17
  logout.main(); //18
}
