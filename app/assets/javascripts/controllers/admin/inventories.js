'use strict';

Application.Controllers.controller('InventoriesController', ['$scope', 'Inventories', function ($scope, Inventories) {
	/* PUBLIC SCOPE */

	Inventories.registerNewArticle = function(va) { console.log("Enregistrer un nouvel article: " + va[0] + "," + va[1] + "," + va[2] + "."); };

	Inventories.registerNewItem = function(va) { console.log("Enregistrer un nouvel item: " + va[0] + "," + va[1] + "."); };
  }
]);

