#const height_value= 800.
#const height_names= 250.
#const width_value= 400.
#const color_considered = "#C1E5AE".
#const color_considered_on_hover = "#6cc13e".
#const color_not_considered = "#E5C2AE".
#const color_not_considered_on_hover = "#c16e3e".

% Window
element(window, window, root).
attribute(window, height, height_value).
attribute(window, width, width_value).
attribute(window, background_color, white).
attribute(window, resizable_x, 1).
attribute(window, resizable_y, 1).
attribute(window, child_layout, absstatic).

% Menu bar
element(m, menu_bar, window).
element(ms, menu_bar_section, m).
attribute(ms, label, "Options").
element(ms_clear, menu_bar_section_item, ms).
attribute(ms_clear, label, "Clear").
callback(ms_clear, click, clear_assumptions).
element(ms_next, menu_bar_section_item, ms).
attribute(ms_next, label, "Next").
callback(ms_next, click, next_solution).

% Top container
element(upper_container, container, window).
attribute(upper_container, height, height_names).
attribute(upper_container, width, width_value).
attribute(upper_container, child_layout, grid).

% Top container titles
in_house_column_label(add_person_container,"People not considered";
                remove_person_container,"People considered").
in_house_column(C):-in_house_column_label(C,_).

element((C,title), label, upper_container):-in_house_column(C).
attribute((C,title), grid_row, 0):-in_house_column(C).
attribute((C,title), height, 20):-in_house_column(C).
attribute((C,title), width, width_value/2):-in_house_column(C).

attribute((C,title), label, L):-in_house_column_label(C,L).
attribute((C,title), font_size, 18):-in_house_column(C).

attribute((remove_person_container,title), grid_column, 1).
attribute((add_person_container,title), grid_column, 0).
attribute((remove_person_container,title), background_color, color_considered ).
attribute((add_person_container,title), background_color, color_not_considered ).

% Add and remove comulmns
element(C, container, upper_container):- in_house_column(C) .
attribute(C, grid_row, 1):-in_house_column(C).
attribute(C, height, height_names-20):-in_house_column(C).
attribute(C, width, width_value/2):-in_house_column(C).
attribute(C, child_layout, flex):-in_house_column(C).
attribute(remove_person_container, grid_column, 1).
attribute(add_person_container, grid_column, 0).

% People to add to the house
can_add(P):-person(P), not in_house(P).

element(person_add(P), label, add_person_container):- can_add(P).
attribute(person_add(P), label, P) :- can_add(P).
attribute(person_add(P), background_color, color_not_considered) :- can_add(P).
callback(person_add(P), click,add_assumption(in_house(P))):- can_add(P).
attribute(person_add(P), on_hover, true) :- can_add(P).
attribute(person_add(P), on_hover_background_color, color_not_considered_on_hover) :- can_add(P).

% People to remove from the house
can_remove(P):- in_house(P).
element(person_remove(P), label, remove_person_container):- can_remove(P).
attribute(person_remove(P), label, P) :- can_remove(P).
attribute(person_remove(P), background_color, color_considered) :- can_remove(P).
callback(person_remove(P), click, remove_assumption(in_house(P))):-can_remove(P).
attribute(person_remove(P), on_hover, true) :- can_remove(P).
attribute(person_remove(P), on_hover_background_color, color_considered_on_hover) :- can_remove(P).

% Rooms container
element(rooms_main_container, container, window).
attribute(rooms_main_container, height, height_value - height_names).
attribute(rooms_main_container, width, width_value).
attribute(rooms_main_container, pos_x, 0).
attribute(rooms_main_container, pos_y, height_names).
attribute(rooms_main_container, child_layout, grid).

% Room container
element(room(I), container, rooms_main_container) :- room(I,_).
attribute(room(I), height, 200) :- room(I,_).
attribute(room(I), width, 200) :- room(I,_).
attribute(room(I), grid_column, (I-1)\2) :- room(I,_).
attribute(room(I), grid_row, (I-1)/2) :- room(I,_).
attribute(room(I), child_layout, absstatic) :- room(I,_).

% Room title
element(room_title(I), label, room(I)) :- room(I,_).
attribute(room_title(I), height, 20) :- room(I,_).
attribute(room_title(I), width, 190) :- room(I,_).
attribute(room_title(I), label, T) :- room(I,T).

% Room beds dropdowns
element(room_dropdown(B,I), dropdown_menu, room(I)) :- bed(B,I).
attribute(room_dropdown(B,I), selected, P) :- assign(bed(B,I),P).
attribute(room_dropdown(B,I), height, 50) :- bed(B,I).
attribute(room_dropdown(B,I), width, 100) :- bed(B,I).
attribute(room_dropdown(B,I), pos_y, B*40):- bed(B,I).

element(mi(B,I,P), dropdown_menu_item, room_dropdown(B,I)) :- _b(assign(bed(B,I),P)).
attribute(mi(B,I,P), label, P) :- _b(assign(bed(B,I),P)).
callback(mi(B,I,P), click, add_assumption(assign(bed(B,I),P))) :- _b(assign(bed(B,I),P)).
%mi(B,I,P) :- _b(bed(B,I)), _b(person(P)).


