'use strict';

Application.Controllers.controller('BasketsController', ['$scope', '$sce', '$sanitize', function ($scope, $sce, $sanitize) {
  /* PUBLIC SCOPE */

   $scope.lendBaskets = function() {

	console.log("Bien dans ses baskets !!!!....[(client_name," + $scope.client_name_for_lend + "); (basket_return_date," + $scope.basket_return_date_for_lend + "); (items_list," + $scope.items_list_for_lend + ")]");

   };

   $scope.returnBaskets = function() {

	console.log("Mal dans ses baskets !!!!....[(client_name," + $scope.client_name_for_return + "); (items_list," + $scope.items_list_for_return + ")]");

   };

   $scope.addItemForReturn = function() {

	var sanitized_element = $sanitize($scope.add_items_barcode_for_return);

        $scope.items_list_for_return = $scope.items_list_for_return + $sce.trustAsHtml(sanitized_element + "<br>");

        $scope.add_items_barcode_for_return = "";

   };

   $scope.deleteItemForReturn = function() {

        const items_lists_array = $scope.items_list_for_return.split("<br>");

        for(let i = 0; i < items_lists_array.length; i++) {

                if(items_lists_array[i] == $scope.delete_items_barcode_for_return) {

                        items_lists_array.splice(i, 1);

                        break;

                }
        }

        $scope.items_list_for_return = items_lists_array.join("<br>")

        $scope.delete_items_barcode_for_return = "";
   };

   $scope.addItemForLend = function() {

	var sanitized_element = $sanitize($scope.add_items_barcode_for_lend);

	$scope.items_list_for_lend = $scope.items_list_for_lend + $sce.trustAsHtml(sanitized_element + "<br>");

	$scope.add_items_barcode_for_lend = "";

   };

   $scope.deleteItemForLend = function() {

	const items_lists_array = $scope.items_list_for_lend.split("<br>");

        for(let i = 0; i < items_lists_array.length; i++) {

		if(items_lists_array[i] == $scope.delete_items_barcode_for_lend) {

			items_lists_array.splice(i, 1);

			break;

		}
	}

	$scope.items_list_for_lend = items_lists_array.join("<br>")

	$scope.delete_items_barcode_for_lend = "";
   };

}]);
