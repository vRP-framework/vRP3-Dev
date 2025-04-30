
window.addEventListener("load", function () {
	const menu = new Menu();
	let select_event = false;

	menu.valid = function (option, mod) {
		const opt = menu.options[option];
		fetch("https://core/menu", {
			method: "POST",
			headers: { "Content-Type": "application/json" },
			body: JSON.stringify({ act: "valid", option, mod })
		});
	}

	menu.onSelect = function (option) {
		if (select_event) {
			fetch("https://core/menu", {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({ act: "select", option })
			});
		}
	};


	window.addEventListener("message", function (evt) {
		const data = evt.data;
		if (data.act === "open_menu") {
			select_event = data.menudata.select_event;
			menu.open(data.menudata);
		} else if (data.act === "close_menu") {
			menu.close();
		} else if (data.act === "update_menu_option") {
			menu.updateOption(data.index, data.title, data.description);
		} else if (data.act === "set_menu_select_event") {
			select_event = data.select_event;
		}
		// KEY STROKES FROM GAME
		else if (data.act === "key") {
			if (!menu.opened) return;
			switch (data.key) {
				case "UP":
					menu.moveUp();
					break;
				case "DOWN":
					menu.moveDown();
					break;
				case "RIGHT":
					menu.valid(menu.selected);
					break;
			}
		}
	});

	// // Keyboard fallback
	// window.addEventListener("keydown", function (e) {
	// 	if (!menu.opened) return;
	// 	switch (e.key) {
	// 		case "ArrowUp":
	// 			menu.moveUp();
	// 			break;
	// 		case "ArrowDown":
	// 			menu.moveDown();
	// 			break;
	// 		case "ArrowRight":
	// 			menu.valid(menu.selected);
	// 			break;
	// 	}
	// });

	window.menu = menu;
});
