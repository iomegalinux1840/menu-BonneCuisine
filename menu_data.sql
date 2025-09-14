--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: davegirard
--

INSERT INTO public.admins VALUES (1, 'admin@labonnecuisine.ca', '$2a$12$q0iyFTCrJqxtwta97K/Kn.PRy0sng.JUN5U4yR3d/bysg8eVksyz.', '2025-09-14 02:02:14.843842', '2025-09-14 02:02:14.843842');


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: davegirard
--

INSERT INTO public.ar_internal_metadata VALUES ('environment', 'development', '2025-09-14 02:02:14.551499', '2025-09-14 02:02:14.551501');
INSERT INTO public.ar_internal_metadata VALUES ('schema_sha1', 'cafec560ba7b7a17dbfdfdd3e14ced59966c66f8', '2025-09-14 02:02:14.553314', '2025-09-14 02:02:14.553315');


--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: davegirard
--

INSERT INTO public.menu_items VALUES (1, 'Poutine Classique', 'Frites fraîches, sauce brune maison et fromage en grains qui fait "squick squick"', 12.99, 'Notre spécialité depuis 1985 • Végétarien', true, 1, '2025-09-14 02:02:14.854478', '2025-09-14 02:02:14.854478');
INSERT INTO public.menu_items VALUES (2, 'Poutine au Smoked Meat', 'Notre poutine classique garnie de généreux morceaux de smoked meat de Montréal', 18.99, 'Best-seller • Contient: gluten', true, 2, '2025-09-14 02:02:14.926703', '2025-09-14 02:02:14.926703');
INSERT INTO public.menu_items VALUES (3, 'Hot-Dog Steamé All-Dressed', 'Deux saucisses steamées, chou, oignons, moutarde et relish dans un pain vapeur', 8.99, 'Style cabane à sucre • Contient: gluten, moutarde', true, 3, '2025-09-14 02:02:14.930798', '2025-09-14 02:02:14.930798');
INSERT INTO public.menu_items VALUES (4, 'Burger Le Bûcheron', 'Double bœuf Angus, bacon, fromage cheddar fort, oignons caramélisés, sauce BBQ érable', 16.99, 'Bœuf local • Contient: gluten, lactose', true, 4, '2025-09-14 02:02:14.934607', '2025-09-14 02:02:14.934607');
INSERT INTO public.menu_items VALUES (5, 'Club Sandwich Québécois', 'Triple étage avec poulet grillé, bacon croustillant, tomates, laitue, mayo maison', 14.99, 'Servi avec frites et salade de chou • Contient: gluten, œufs', true, 5, '2025-09-14 02:02:14.942684', '2025-09-14 02:02:14.942684');
INSERT INTO public.menu_items VALUES (6, 'Guédille aux Crevettes', 'Pain hot-dog grillé rempli de crevettes nordiques, mayo citronnée et ciboulette', 15.99, 'Crevettes de Matane • Contient: crustacés, gluten', true, 6, '2025-09-14 02:02:14.947257', '2025-09-14 02:02:14.947257');
INSERT INTO public.menu_items VALUES (7, 'Tourtière du Lac', 'Pâté à la viande traditionnel servi avec ketchup aux fruits maison et salade verte', 13.99, 'Recette de grand-maman • Contient: gluten', true, 7, '2025-09-14 02:02:14.951819', '2025-09-14 02:02:14.951819');
INSERT INTO public.menu_items VALUES (8, 'Rondelles d''Oignon Géantes', 'Oignons panés croustillants servis avec sauce ranch épicée', 9.99, 'À partager • Végétarien', true, 8, '2025-09-14 02:02:14.959045', '2025-09-14 02:02:14.959045');
INSERT INTO public.menu_items VALUES (9, 'Pouding Chômeur', 'Gâteau éponge nappé de sirop d''érable, servi chaud avec crème glacée vanille', 7.99, 'Dessert réconfortant • Contient: gluten, lactose', true, 9, '2025-09-14 02:02:14.964687', '2025-09-14 02:02:14.964687');
INSERT INTO public.menu_items VALUES (10, 'Queue de Castor', 'Pâte frite étirée, cannelle et sucre, avec option Nutella ou sirop d''érable', 6.99, 'Chaud et croustillant • Contient: gluten', true, 10, '2025-09-14 02:02:14.969957', '2025-09-14 02:02:14.969957');
INSERT INTO public.menu_items VALUES (11, 'Tarte au Sucre', 'Tarte traditionnelle au sucre brun et crème, servie avec crème fouettée', 5.99, 'Fait maison • Contient: gluten, lactose', true, 11, '2025-09-14 02:02:14.978188', '2025-09-14 02:02:14.978188');
INSERT INTO public.menu_items VALUES (12, 'Flotteur à la Bière d''Épinette', 'Bière d''épinette Bec Cola avec boule de crème glacée vanille', 4.99, 'Rafraîchissant et nostalgique • Sans alcool', true, 12, '2025-09-14 02:02:14.984353', '2025-09-14 02:02:14.984353');


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: davegirard
--

INSERT INTO public.schema_migrations VALUES ('2');
INSERT INTO public.schema_migrations VALUES ('1');


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: davegirard
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- Name: menu_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: davegirard
--

SELECT pg_catalog.setval('public.menu_items_id_seq', 12, true);


--
-- PostgreSQL database dump complete
--

