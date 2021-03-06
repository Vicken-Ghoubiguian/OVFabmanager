# frozen_string_literal: true

if StatisticIndex.count.zero?
  StatisticIndex.create!([
                           { id: 1, es_type_key: 'subscription', label: I18n.t('statistics.subscriptions') },
                           { id: 2, es_type_key: 'machine', label: I18n.t('statistics.machines_hours') },
                           { id: 3, es_type_key: 'training', label: I18n.t('statistics.trainings') },
                           { id: 4, es_type_key: 'event', label: I18n.t('statistics.events') },
                           { id: 5, es_type_key: 'account', label: I18n.t('statistics.registrations'), ca: false },
                           { id: 6, es_type_key: 'project', label: I18n.t('statistics.projects'), ca: false },
                           { id: 7, es_type_key: 'user', label: I18n.t('statistics.users'), table: false, ca: false }
                         ])
  connection = ActiveRecord::Base.connection
  connection.execute("SELECT setval('statistic_indices_id_seq', 7);") if connection.instance_values['config'][:adapter] == 'postgresql'
end

if StatisticField.count.zero?
  StatisticField.create!([
                           # available data_types : index, number, date, text, list
                           { key: 'trainingId', label: I18n.t('statistics.training_id'), statistic_index_id: 3, data_type: 'index' },
                           { key: 'trainingDate', label: I18n.t('statistics.training_date'), statistic_index_id: 3, data_type: 'date' },
                           { key: 'eventId', label: I18n.t('statistics.event_id'), statistic_index_id: 4, data_type: 'index' },
                           { key: 'eventDate', label: I18n.t('statistics.event_date'), statistic_index_id: 4, data_type: 'date' },
                           { key: 'themes', label: I18n.t('statistics.themes'), statistic_index_id: 6, data_type: 'list' },
                           { key: 'components', label: I18n.t('statistics.components'), statistic_index_id: 6, data_type: 'list' },
                           { key: 'machines', label: I18n.t('statistics.machines'), statistic_index_id: 6, data_type: 'list' },
                           { key: 'name', label: I18n.t('statistics.event_name'), statistic_index_id: 4, data_type: 'text' },
                           { key: 'userId', label: I18n.t('statistics.user_id'), statistic_index_id: 7, data_type: 'index' },
                           { key: 'eventTheme', label: I18n.t('statistics.event_theme'), statistic_index_id: 4, data_type: 'text' },
                           { key: 'ageRange', label: I18n.t('statistics.age_range'), statistic_index_id: 4, data_type: 'text' }
                         ])
end

unless StatisticField.find_by(key:'groupName').try(:label)
  field = StatisticField.find_or_initialize_by(key: 'groupName')
  field.label = 'Groupe'
  field.statistic_index_id = 1
  field.data_type = 'text'
  field.save!
end

if StatisticType.count.zero?
  StatisticType.create!([
                          { statistic_index_id: 2, key: 'booking', label: I18n.t('statistics.bookings'), graph: true, simple: true },
                          { statistic_index_id: 2, key: 'hour', label: I18n.t('statistics.hours_number'), graph: true, simple: false },
                          { statistic_index_id: 3, key: 'booking', label: I18n.t('statistics.bookings'), graph: false, simple: true },
                          { statistic_index_id: 3, key: 'hour', label: I18n.t('statistics.hours_number'), graph: false, simple: false },
                          { statistic_index_id: 4, key: 'booking', label: I18n.t('statistics.tickets_number'), graph: false,
                            simple: false },
                          { statistic_index_id: 4, key: 'hour', label: I18n.t('statistics.hours_number'), graph: false, simple: false },
                          { statistic_index_id: 5, key: 'member', label: I18n.t('statistics.users'), graph: true, simple: true },
                          { statistic_index_id: 6, key: 'project', label: I18n.t('statistics.projects'), graph: false, simple: true },
                          { statistic_index_id: 7, key: 'revenue', label: I18n.t('statistics.revenue'), graph: false, simple: false }
                        ])
end

if StatisticSubType.count.zero?
  StatisticSubType.create!([
                             { key: 'created', label: I18n.t('statistics.account_creation'),
                               statistic_types: StatisticIndex.find_by(es_type_key: 'account').statistic_types },
                             { key: 'published', label:I18n.t('statistics.project_publication'),
                               statistic_types: StatisticIndex.find_by(es_type_key: 'project').statistic_types }
                           ])
end

if StatisticGraph.count.zero?
  StatisticGraph.create!([
                           { statistic_index_id: 1, chart_type: 'stackedAreaChart', limit: 0 },
                           { statistic_index_id: 2, chart_type: 'stackedAreaChart', limit: 0 },
                           { statistic_index_id: 3, chart_type: 'discreteBarChart', limit: 10 },
                           { statistic_index_id: 4, chart_type: 'discreteBarChart', limit: 10 },
                           { statistic_index_id: 5, chart_type: 'lineChart', limit: 0 },
                           { statistic_index_id: 7, chart_type: 'discreteBarChart', limit: 10 }
                         ])
end

if Group.count.zero?
  Group.create!([
                  { name: 'standard, association', slug: 'standard' },
                  { name: "??tudiant, - de 25 ans, enseignant, demandeur d'emploi", slug: 'student' },
                  { name: 'artisan, commer??ant, chercheur, auto-entrepreneur', slug: 'merchant' },
                  { name: 'PME, PMI, SARL, SA', slug: 'business' }
                ])
end

Group.create! name: I18n.t('group.admins'), slug: 'admins' unless Group.find_by(slug: 'admins')

# Create the default admin if none exists yet
if Role.where(name: 'admin').joins(:users).count.zero?
  admin = User.new(username: 'admin', email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PASSWORD'],
                   password_confirmation: Rails.application.secrets.admin_password, group_id: Group.find_by(slug: 'admins').id,
                   profile_attributes: { first_name: 'admin', last_name: 'admin', phone: '0123456789' },
                   statistic_profile_attributes: { gender: true, birthday: Time.now })
  admin.add_role 'admin'
  admin.save!
end

if Component.count.zero?
  Component.create!([
                      { name: 'Silicone' },
                      { name: 'Vinyle' },
                      { name: 'Bois Contre plaqu??' },
                      { name: 'Bois Medium' },
                      { name: 'Plexi / PMMA' },
                      { name: 'Flex' },
                      { name: 'Vinyle' },
                      { name: 'Parafine' },
                      { name: 'Fibre de verre' },
                      { name: 'R??sine' }
                    ])
end

if Licence.count.zero?
  Licence.create!([
                    { name: 'Attribution (BY)', description: 'Le titulaire des droits autorise toute exploitation de l?????uvre, y compris ??' \
                      ' des fins commerciales, ainsi que la cr??ation d?????uvres d??riv??es, dont la distribution est ??galement autoris?? sans ' \
                      'restriction, ?? condition de l???attribuer ?? son l???auteur en citant son nom. Cette licence est recommand??e pour la ' \
                      'diffusion et l???utilisation maximale des ??uvres.' },
                    { name: 'Attribution + Pas de modification (BY ND)', description: 'Le titulaire des droits autorise toute utilisation' \
                      ' de l?????uvre originale (y compris ?? des fins commerciales), mais n???autorise pas la cr??ation d?????uvres d??riv??es.' },
                    { name: "Attribution + Pas d'Utilisation Commerciale + Pas de Modification (BY NC ND)", description: 'Le titulaire ' \
                      'des droits autorise l???utilisation de l?????uvre originale ?? des fins non commerciales, mais n???autorise pas la ' \
                      'cr??ation d?????uvres d??riv??s.' },
                    { name: "Attribution + Pas d'Utilisation Commerciale (BY NC)", description: 'Le titulaire des droits autorise ' \
                      'l???exploitation de l?????uvre, ainsi que la cr??ation d?????uvres d??riv??es, ?? condition qu???il ne s???agisse pas d???une ' \
                      'utilisation commerciale (les utilisations commerciales restant soumises ?? son autorisation).' },
                    { name: "Attribution + Pas d'Utilisation Commerciale + Partage dans les m??mes conditions (BY NC SA)", description:
                      'Le titulaire des droits autorise l???exploitation de l?????uvre originale ?? des fins non commerciales, ainsi que la ' \
                      'cr??ation d?????uvres d??riv??es, ?? condition qu???elles soient distribu??es sous une licence identique ?? celle qui r??git ' \
                      'l?????uvre originale.' },
                    { name: 'Attribution + Partage dans les m??mes conditions (BY SA)', description: 'Le titulaire des droits autorise ' \
                      'toute utilisation de l?????uvre originale (y compris ?? des fins commerciales) ainsi que la cr??ation d?????uvres d??riv??es' \
                      ', ?? condition qu???elles soient distribu??es sous une licence identique ?? celle qui r??git l?????uvre originale. Cette' \
                      'licence est souvent compar??e aux licences ?? copyleft ?? des logiciels libres. C???est la licence utilis??e par ' \
                      'Wikipedia.' }
                  ])
end

if Theme.count.zero?
  Theme.create!([
                  { name: 'Vie quotidienne' },
                  { name: 'Robotique' },
                  { name: 'Arduine' },
                  { name: 'Capteurs' },
                  { name: 'Musique' },
                  { name: 'Sport' },
                  { name: 'Autre' }
                ])
end

if Training.count.zero?
  Training.create!([
                     { name: 'Formation Imprimante 3D', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ' \
                       'eiusmod tempor incididunt ut labore et dolore magna aliqua.' },
                     { name: 'Formation Laser / Vinyle', description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris' \
                       ' nisi ut aliquip ex ea commodo consequat.' },
                     { name: 'Formation Petite fraiseuse numerique', description: 'Duis aute irure dolor in reprehenderit in voluptate ' \
                       'velit esse cillum dolore eu fugiat nulla pariatur.' },
                     { name: 'Formation Shopbot Grande Fraiseuse', description: 'Excepteur sint occaecat cupidatat non proident, sunt in ' \
                       'culpa qui officia deserunt mollit anim id est laborum.' },
                     { name: 'Formation logiciel 2D', description: 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem ' \
                       'accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi ' \
                       'architecto beatae vitae dicta sunt explicabo.' }
                   ])

  TrainingsPricing.all.each do |p|
    p.update_columns(amount: (rand * 50 + 5).floor * 100)
  end
end

if Space.count.zero?
  Space.create!([
		  { name: 'Coworking', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', default_places: 10},
		  { name: 'Impression 3D', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', default_places: 10},
		  { name: 'Robotique', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', default_places: 10},
		  { name: '??lectronique', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', default_places: 10},
		  { name: 'R??alit?? augment??e / R??alit?? virtuelle M??dias', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', default_places: 10},
		  { name: 'Laser', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', default_places: 10},
		  { name: 'Atelier', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', default_places: 10}
		])

end

if Asset.count.zero?
  Asset.create!([
		 { id: 1, viewable_id: 1, viewable_type: 'CustomAsset', attachment: 'dl_mira.png', type: 'CustomAssetFile'}, 
		 { id: 2, viewable_id: 1, viewable_type: 'Space', attachment: 'space_image.png', type: 'SpaceImage'},
		 { id: 3, viewable_id: 2, viewable_type: 'Space', attachment: 'space_image.png', type: 'SpaceImage'},
		 { id: 4, viewable_id: 3, viewable_type: 'Space', attachment: 'space_image.png', type: 'SpaceImage'},
		 { id: 5, viewable_id: 4, viewable_type: 'Space', attachment: 'space_image.png', type: 'SpaceImage'},
		 { id: 6, viewable_id: 5, viewable_type: 'Space', attachment: 'space_image.png', type: 'SpaceImage'},
		 { id: 7, viewable_id: 6, viewable_type: 'Space', attachment: 'space_image.png', type: 'SpaceImage'},
		 { id: 8, viewable_id: 7, viewable_type: 'Space', attachment: 'space_image.png', type: 'SpaceImage'},
		 { id: 9, viewable_id: 1, viewable_type: 'Machine', attachment: 'machine_image.png', type: 'MachineImage'},
		 { id: 10, viewable_id: 2, viewable_type: 'Machine', attachment: 'machine_image.png', type: 'MachineImage'}
		])

end

if CustomAsset.count.zero?
  CustomAsset.create!([
		 { id: 1, name: 'favicon-file' }
		])

end

if Machine.count.zero?
  Machine.create!([
                    { name: 'D??coupeuse laser', description: "Pr??paration ?? l'utilisation de l'EPILOG Legend 36EXT\r\nInformations" \
                      " g??n??rales    \r\n      Pour la d??coupe, il suffit d'apporter votre fichier vectoris?? type illustrator, svg ou dxf" \
                      " avec des \"lignes de coupe\" d'une ??paisseur inf??rieur ?? 0,01 mm et la machine s'occupera du reste!\r\n     La " \
                      'gravure est bas??e sur le spectre noir et blanc. Les nuances sont obtenues par diff??rentes profondeurs de gravure ' \
                      "correspondant aux niveaux de gris de votre image. Il suffit pour cela d'apporter une image scann??e ou un fichier " \
                      "photo en noir et blanc pour pouvoir reproduire celle-ci sur votre support! \r\nQuels types de mat??riaux pouvons " \
                      "nous graver/d??couper?\r\n     Du bois au tissu, du plexiglass au cuir, cette machine permet de d??couper et graver " \
                      "la plupart des mat??riaux sauf les m??taux. La gravure est n??anmoins possible sur les m??taux recouverts d'une couche" \
                      " de peinture ou les aluminiums anodis??s. \r\n        Concernant l'??paisseur des mat??riaux d??coup??s, il est " \
                      "pr??f??rable de ne pas d??passer 5 mm pour le bois et 6 mm pour le plexiglass.\r\n", spec: "Puissance: 40W\r\nSurface" \
                      " de travail: 914x609 mm \r\nEpaisseur maximale de la mati??re: 305mm\r\nSource laser: tube laser type CO2\r\n" \
                      'Contr??les de vitesse et de puissance: ces deux param??tres sont ajustables en fonction du mat??riau (de 1% ?? 100%) .' \
                      "\r\n", slug: 'decoupeuse-laser' },
		    { name: 'Imprimante 3D', description: "L'utimaker est une imprimante 3D  low cost utilisant une technologie FFF " \
                      "(Fused Filament Fabrication) avec extrusion thermoplastique.\r\nC'est une machine id??ale pour r??aliser rapidement " \
                      "des prototypes 3D dans des couleurs diff??rentes.\r\n", spec: "Surface maximale de travail: 210x210x220mm \r\n" \
                      "R??solution m??chanique: 0,02 mm \r\nPr??cision de position: +/- 0,05 \r\nLogiciel utilis??: Cura\r\nFormats de " \
                      "fichier accept??s: STL \r\nMat??riaux utilis??s: PLA (en stock).", slug: 'imprimante-3d' },
                    { name: 'D??coupeuse vinyle', description: "Pr??paration ?? l'utilisation de la Roland CAMM-1 GX24\r\nInformations " \
                      "g??n??rales        \r\n     Envie de r??aliser un tee shirt personnalis?? ? Un sticker ?? l'effigie votre groupe " \
                      "pr??f??r?? ? Un masque pour la r??alisation d'un circuit imprim??? Pour cela, il suffit simplement de venir avec votre" \
                      " fichier vectoris?? (ne pas oublier de vectoriser les textes) type illustrator svg ou dxf.\r\n \r\nMat??riaux " \
                      "utilis??s:\r\n    Cette machine permet de d??couper principalement du vinyle,vinyle r??fl??chissant, flex.\r\n",
                      spec: "Largeurs de support accept??es: de 50 mm ?? 700 mm\r\nVitesse de d??coupe: 50 cm/sec\r\nR??solution m??canique: " \
                      "0,0125 mm/pas\r\n", slug: 'decoupeuse-vinyle' },
                    { name: 'Shopbot / Grande fraiseuse', description: "La fraiseuse num??rique ShopBot PRS standard\r\nInformations " \
                      "g??n??rales\r\nCette machine est un fraiseuse 3 axes id??ale pour l'usinage de pi??ces de grandes dimensions. De la " \
                      "r??alisation d'une chaise ou d'un meuble jusqu'?? la construction d'une maison ou d'un assemblage immense, le " \
                      "ShopBot ouvre de nombreuses portes ?? votre imagination! \r\nMat??riaux usinables\r\nLes principaux mat??riaux " \
                      "usinables sont le bois, le plastique, le laiton et bien d'autres.\r\nCette machine n'usine pas les m??taux.\r\n",
                      spec: "Surface maximale de travail: 2440x1220x150 (Z) mm\r\nLogiciel utilis??: Partworks 2D & 3D\r\nR??solution " \
                      "m??canique: 0,015 mm\r\nPr??cision de la position: +/- 0,127mm\r\nFormats accept??s: DXF, STL \r\n",
                      slug: 'shopbot-grande-fraiseuse' },
                    { name: 'Petite Fraiseuse', description: "La fraiseuse num??rique Roland Modela MDX-20\r\nInformations g??n??rales" \
                      "\r\nCette machine est utilis??e  pour l'usinage et le scannage 3D de pr??cision. Elle permet principalement d'usiner" \
                      ' des circuits imprim??s et des moules de petite taille. Le faible diam??tre des fraises utilis??es (?? 0,3 mm ??  ?? 6mm' \
                      ") induit que certains temps d'usinages peuvent ??tres long (> 12h), c'est pourquoi cette fraiseuse peut ??tre " \
                      "laiss??e en autonomie toute une nuit afin d'obtenir le plus pr??cis des usinages au FabLab.\r\nMat??riaux usinables:" \
                      "\r\nLes principaux mat??riaux usinables sont le bois, pl??tre, r??sine, cire usinable, cuivre.\r\n",
                      spec: "Taille du plateau X/Y : 220 mm x 160 mm\r\nVolume maximal de travail: 203,2 mm (X), 152,4 mm (Y), 60,5 mm " \
                      "(Z)\r\nPr??cision usinage: 0,00625 mm\r\nPr??cision scannage: r??glable de 0,05 ?? 5 mm (axes X,Y) et 0,025 mm (axe Z)" \
                      "\r\nVitesse d'analyse (scannage): 4-15 mm/sec\r\n \r\n \r\nLogiciel utilis?? pour le fraisage: Roland Modela player" \
                      " 4 \r\nLogiciel utilis?? pour l'usinage de circuits imprim??s: Cad.py (linux)\r\nFormats accept??s: STL,PNG 3D\r\n" \
                      "Format d'exportation des donn??es scann??es: DXF, VRML, STL, 3DMF, IGES, Grayscale, Point Group et BMP\r\n",
                      slug: 'petite-fraiseuse' },
                  ])

  Price.all.each do |p|
    p.update_columns(amount: (rand * 50 + 5).floor * 100)
  end
end


if Category.count.zero?
  Category.create!(
    [
      { name: 'Stage' },
      { name: 'Atelier' }
    ]
  )
end

unless Setting.find_by(name: 'about_body').try(:value)
  setting = Setting.find_or_initialize_by(name: 'about_body')
  setting.value = '<p>La Fabrique du <a href=\"http://fab-manager.com\" target=\"_blank\">Fab-manager</a> est un' \
  ' atelier de fabrication num??rique o?? l???on peut utiliser des machines de d??coupe, des imprimantes 3D,??? permettant' \
  ' de travailler sur des mat??riaux vari??s : plastique, bois, carton, vinyle, ??? afin de cr??er toute sorte d???objet gr??ce' \
  ' ?? la conception assist??e par ordinateur ou ?? l?????lectronique.  Mais le Fab Lab est aussi un lieu d?????change de' \
  ' comp??tences technique. </p>' \
  ' <p>La Fabrique du <a href=\"http://fab-manager.com\" target=\"_blank\">Fab-manager</a> est un espace' \
 ' permanent : ouvert ?? tous, il offre la possibilit?? de r??aliser des objets soi-m??me, de partager ses' \
  ' comp??tences et d???apprendre au contact des m??diateurs du Fab Lab et des autres usagers. </p>' \
  '<p>La formation au Fab Lab s???appuie sur des projets et le partage de connaissances : vous devez prendre' \
  ' part ?? la capitalisation des connaissances et ?? l???instruction des autres utilisateurs.</p>'
  setting.save
end

unless Setting.find_by(name: 'about_title').try(:value)
  setting = Setting.find_or_initialize_by(name: 'about_title')
  setting.value = 'Imaginer, Fabriquer, <br>Partager ?? la Fabrique <br> du Fab-manager'
  setting.save
end

unless Setting.find_by(name: 'about_contacts').try(:value)
  setting = Setting.find_or_initialize_by(name: 'about_contacts')
  setting.value = '<dl>' \
  '<dt>Manager Fab Lab :</dt>' \
  '<dd>contact@fab-manager.com</dd>' \
  '<dt>Responsable m??diation :</dt>' \
  '<dd>contact@fab-manager.com</dd>' \
  '<dt>Animateur scientifique :</dt>' \
  '<dd>lcontact@fab-manager.com</dd>' \
  '</dl>' \
  '<br><br>' \
  "<p><a href='http://fab-manager.com'>Visitez le site de Fab-manager</a></p>"
  setting.save
end

unless Setting.find_by(name: 'twitter_name').try(:value)
  setting = Setting.find_or_initialize_by(name: 'twitter_name')
  setting.value = 'fab_manager'
  setting.save
end

unless Setting.find_by(name: 'machine_explications_alert').try(:value)
  setting = Setting.find_or_initialize_by(name: 'machine_explications_alert')
  setting.value = "Tout achat d'heure machine est d??finitif. Aucune" \
  ' annulation ne pourra ??tre effectu??e, n??anmoins au plus tard 24h avant le cr??neau fix??, vous pouvez en' \
  " modifier la date et l'horaire ?? votre convenance et en fonction du calendrier propos??. Pass?? ce d??lais," \
  ' aucun changement ne pourra ??tre effectu??.'
  setting.save
end

unless Setting.find_by(name: 'training_explications_alert').try(:value)
  setting = Setting.find_or_initialize_by(name: 'training_explications_alert')
  setting.value = 'Toute r??servation de formation est d??finitive.' \
  ' Aucune annulation ne pourra ??tre effectu??e, n??anmoins au plus tard 24h avant le cr??neau fix??, vous pouvez' \
  " en modifier la date et l'horaire ?? votre convenance et en fonction du calendrier propos??. Pass?? ce d??lais," \
  ' aucun changement ne pourra ??tre effectu??.'
  setting.save
end

unless Setting.find_by(name: 'subscription_explications_alert').try(:value)
  setting = Setting.find_or_initialize_by(name: 'subscription_explications_alert')
  setting.value = '<p><b>R??gle sur la date de d??but des abonnements</b><br></p><ul><li>' \
  ' <span style=\"font-size: 1.6rem; line-height: 2.4rem;\">Si vous ??tes un nouvel utilisateur - i.e aucune ' \
  " formation d'enregistr??e sur le site - votre abonnement d??butera ?? la date de r??servation de votre premi??re " \
  ' formation.</span><br></li><li><span style=\"font-size: 1.6rem; line-height: 2.4rem;\">Si vous avez d??j?? une ' \
  " formation ou plus de valid??e, votre abonnement d??butera ?? la date de votre achat d'abonnement.</span></li>" \
  " </ul><p>Merci de bien prendre ses informations en compte, et merci de votre compr??hension. L'??quipe du Fab Lab.<br>" \
  ' </p><p></p>'
  setting.save
end

unless Setting.find_by(name: 'invoice_logo').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_logo')
  setting.value = 'iVBORw0KGgoAAAANSUhEUgAAAG0AAABZCAYAAAA0E6rtAAAACXBIWXMAAAsTAAALEwEAmpwYAAA57WlUWHRYTUw6Y29tLmFkb2JlLnhtc' \
                  'AAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PS' \
                  'JhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxMzggNzkuMTU5ODI0LCAyMDE2LzA5LzE0LTAxOjA5OjA' \
                  'xICAgICAgICAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMi' \
                  'PgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb' \
                  '20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgICAgICAgIC' \
                  'AgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIgogICAgICAgICAgICB4bWxuczp4bXBNTT0' \
                  'iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIKICAgICAgICAgICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20v' \
                  'eGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmL' \
                  'zEuMC8iCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPHhtcDpDcm' \
                  'VhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ0MgMjAxNyAoV2luZG93cyk8L3htcDpDcmVhdG9yVG9vbD4KICAgICAgICAgPHhtcDpDcmV' \
                  'hdGVEYXRlPjIwMTctMDEtMDNUMTE6MTg6MTgrMDE6MDA8L3htcDpDcmVhdGVEYXRlPgogICAgICAgICA8eG1wOk1vZGlmeURhdGU'
  setting.save
end

unless Setting.find_by(name: 'invoice_reference').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_reference')
  setting.value = 'YYMMmmmX[/VL]R[/A]'
  setting.save
end

unless Setting.find_by(name: 'invoice_code-active').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_code-active')
  setting.value = 'true'
  setting.save
end

unless Setting.find_by(name: 'invoice_code-value').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_code-value')
  setting.value = 'INMEDFABLAB'
  setting.save
end

unless Setting.find_by(name: 'invoice_order-nb').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_order-nb')
  setting.value = 'nnnnnn-MM-YY'
  setting.save
end

unless Setting.find_by(name: 'invoice_VAT-active').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_VAT-active')
  setting.value = 'false'
  setting.save
end

unless Setting.find_by(name: 'invoice_VAT-rate').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_VAT-rate')
  setting.value = '20.0'
  setting.save
end

unless Setting.find_by(name: 'invoice_text').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_text')
  setting.value = "Notre association n'est pas assujettie ?? la TVA"
  setting.save
end

unless Setting.find_by(name: 'invoice_legals').try(:value)
  setting = Setting.find_or_initialize_by(name: 'invoice_legals')
  setting.value = 'La fabrique<br/>' \
                  '68 rue Louise Michel 38100 GRENOBLE France<br/>' \
                  'T??l. : +33 1 23 45 67 98<br/>' \
                  'Fax. : +33 1 23 45 67 98<br/>' \
                  'SIRET : 237 082 474 00006 - APE 913 E'
  setting.save
end

unless Setting.find_by(name: 'booking_window_start').try(:value)
  setting = Setting.find_or_initialize_by(name: 'booking_window_start')
  setting.value = '1970-01-01 08:00:00'
  setting.save
end

unless Setting.find_by(name: 'booking_window_end').try(:value)
  setting = Setting.find_or_initialize_by(name: 'booking_window_end')
  setting.value = '1970-01-01 23:59:59'
  setting.save
end

unless Setting.find_by(name: 'booking_move_enable').try(:value)
  setting = Setting.find_or_initialize_by(name: 'booking_move_enable')
  setting.value = 'true'
  setting.save
end

unless Setting.find_by(name: 'booking_move_delay').try(:value)
  setting = Setting.find_or_initialize_by(name: 'booking_move_delay')
  setting.value = '24'
  setting.save
end

unless Setting.find_by(name: 'booking_cancel_enable').try(:value)
  setting = Setting.find_or_initialize_by(name: 'booking_cancel_enable')
  setting.value = 'false'
  setting.save
end

unless Setting.find_by(name: 'booking_cancel_delay').try(:value)
  setting = Setting.find_or_initialize_by(name: 'booking_cancel_delay')
  setting.value = '24'
  setting.save
end

unless Setting.find_by(name: 'main_color').try(:value)
  setting = Setting.find_or_initialize_by(name: 'main_color')
  setting.value = '#c5007b'
  setting.save
end

unless Setting.find_by(name: 'secondary_color').try(:value)
  setting = Setting.find_or_initialize_by(name: 'secondary_color')
  setting.value = '#608da1'
  setting.save
end

Stylesheet.build_sheet!

unless Setting.find_by(name: 'training_information_message').try(:value)
  setting = Setting.find_or_initialize_by(name: 'training_information_message')
  setting.value = "Avant de r??server une formation, nous vous conseillons de consulter nos offres d'abonnement qui"+
                  ' proposent des conditions avantageuses sur le prix des formations et les heures machines.'
  setting.save
end


unless Setting.find_by(name: 'fablab_name').try(:value)
  setting = Setting.find_or_initialize_by(name: 'fablab_name')
  setting.value = 'Fablab ORLES VALLEY'
  setting.save
end

unless Setting.find_by(name: 'name_genre').try(:value)
  setting = Setting.find_or_initialize_by(name: 'name_genre')
  setting.value = 'male'
  setting.save
end


unless DatabaseProvider.count.positive?
  db_provider = DatabaseProvider.new
  db_provider.save

  unless AuthProvider.find_by(providable_type: DatabaseProvider.name)
    provider = AuthProvider.new
    provider.name = 'FabManager'
    provider.providable = db_provider
    provider.status = 'active'
    provider.save
  end
end

unless Setting.find_by(name: 'reminder_enable').try(:value)
  setting = Setting.find_or_initialize_by(name: 'reminder_enable')
  setting.value = 'true'
  setting.save
end

unless Setting.find_by(name: 'reminder_delay').try(:value)
  setting = Setting.find_or_initialize_by(name: 'reminder_delay')
  setting.value = '24'
  setting.save
end

unless Setting.find_by(name: 'visibility_yearly').try(:value)
  setting = Setting.find_or_initialize_by(name: 'visibility_yearly')
  setting.value = '3'
  setting.save
end

unless Setting.find_by(name: 'visibility_others').try(:value)
  setting = Setting.find_or_initialize_by(name: 'visibility_others')
  setting.value = '1'
  setting.save
end

unless Setting.find_by(name: 'display_name_enable').try(:value)
  setting = Setting.find_or_initialize_by(name: 'display_name_enable')
  setting.value = 'false'
  setting.save
end

unless Setting.find_by(name: 'machines_sort_by').try(:value)
  setting = Setting.find_or_initialize_by(name: 'machines_sort_by')
  setting.value = 'default'
  setting.save
end

unless Setting.find_by(name: 'privacy_draft').try(:value)
  setting = Setting.find_or_initialize_by(name: 'privacy_draft')
  setting.value = "<p>La pr??sente politique de confidentialit?? d??finit et vous informe de la mani??re dont _________ utilise et prot??ge les
  informations que vous nous transmettez, le cas ??ch??ant, lorsque vous utilisez le pr??sent site accessible ?? partir de l???URL suivante :
  _________ (ci-apr??s le ?? Site ??).</p><p>Veuillez noter que cette politique de confidentialit?? est susceptible d?????tre modifi??e ou
  compl??t??e ?? tout moment par _________, notamment en vue de se conformer ?? toute ??volution l??gislative, r??glementaire, jurisprudentielle
  ou technologique. Dans un tel cas, la date de sa mise ?? jour sera clairement identifi??e en t??te de la pr??sente politique et l'Utilisateur
  sera inform?? par courriel. Ces modifications engagent l???Utilisateur d??s leur mise en ligne. Il convient par cons??quent que l???Utilisateur
  consulte r??guli??rement la pr??sente politique de confidentialit?? et d???utilisation des cookies afin de prendre connaissance de ses
  ??ventuelles modifications.</p><h3>I. DONN??ES PERSONNELLES</h3><p>D???une mani??re g??n??rale, il vous est possible de visiter le site de
  _________ sans communiquer aucune information personnelle vous concernant. En toute hypoth??se, vous n?????tes en aucune mani??re oblig?? de
  transmettre ces informations ?? _________.</p><p>N??anmoins, en cas de refus, il se peut que vous ne puissiez pas b??n??ficier de
  certaines informations ou services que vous avez demand??. A ce titre en effet, _________ peut ??tre amen?? dans certains cas ?? vous
  demander de renseigner vos nom, pr??nom, pseudonyme, sexe, adresse mail, num??ro de t??l??phone, entreprise et date de naissance (ci-apr??s
  vos ?? Informations Personnelles ??). En fournissant ces informations, vous acceptez express??ment qu???elles soient trait??es par
  _________, aux fins indiqu??es au point 2 ci-dessous.</p><p>Conform??ment au R??glement G??n??ral sur la Protection des Donn??es (General
  Data Protection Regulation) adopt?? par le Parlement europ??en le 14 avril 2016, et ?? la Loi Informatique et Libert??s du 6 janvier 1978
  modifi??e, _________ vous informe des points suivants :</p><h4>1. Identit?? du responsable du traitement</h4><p>Le responsable du
  traitement est (la soci??t??/l'association) _________ ??? (adresse) _________, (code postal) _________ (ville)&nbsp;_________ ??? (Pays)
  _________ .</p><h4>2. Finalit??s du traitement</h4><p>_________ est susceptible de traiter vos Informations Personnelles :</p><p>(a)
  aux fins de vous fournir les informations ou les services que vous avez demand??s (notamment : l'envoi de notifications relatives ??
  vos activit??s sur le Site, l???envoi de la Newsletter, la correspondance par email, l???envoi d???informations commerciales, livres
  blancs ou encore l?????valuation de votre niveau de satisfaction quant aux services propos??s) ;</p><p>(b) aux fins de recueillir des
  informations nous permettant d???am??liorer notre Site, nos produits et services (notamment par le biais de cookies) ;</p><p>(c)
  aux fins de pouvoir vous contacter ?? propos de diff??rents ??v??nements relatifs ?? _________, incluant notamment la mise ?? jour des
  produits et le support client.</p><h4>3. Destinataires</h4><p>Seul _________ est destinataire de vos Informations Personnelles.
  Celles-ci, que ce soit sous forme individuelle ou agr??g??e, ne sont jamais transmises ?? un tiers, nonobstant les sous-traitants
  auxquels _________ fait appel (vous trouverez de plus amples informations ?? leur sujet au point 7 ci-dessous). Ni _________,
  ni l???un quelconque de ses sous-traitants, ne proc??dent ?? la commercialisation des donn??es personnelles des visiteurs et Utilisateurs de
  son Site.</p><h4>4. Dur??e de conservation</h4><p>Vos Informations Personnelles sont conserv??es par _________ uniquement pour le temps
  correspondant ?? la finalit?? de la collecte tel qu???indiqu?? en 2 ci-dessus qui ne saurait en tout ??tat de cause exc??der 36 mois.</p><h4>5.
  Droits Informatique et Libert??s</h4><p>Vous disposez des droits suivants concernant vos Informations Personnelles, que vous pouvez exercer
  en nous ??crivant ?? l???adresse postale mentionn??e au point 1 ou en contactant le d??l??gu?? ?? la protection des donn??es, dont l'adresse est
  mentionn??e ci-contre.</p><p><b>o Droit d???acc??s et de communication des donn??es</b></p><p>Vous avez la facult?? d???acc??der aux Informations
  Personnelles qui vous concernent.</p><p>Cependant, en raison de l???obligation de s??curit?? et de confidentialit?? dans le traitement des
  donn??es ?? caract??re personnel qui incombe ?? _________, vous ??tes inform?? que votre demande sera trait??e sous r??serve que vous apportiez la
  preuve de votre identit??, notamment par la production d???un scan de votre titre d???identit?? valide (en cas de demande par voie ??lectronique)
  ou d???une photocopie sign??e de votre titre d???identit?? valide (en cas de demande adress??e par ??crit).</p><p>_________ vous informe qu???il
  sera en droit, le cas ??ch??ant, de s???opposer aux demandes manifestement abusives (de par leur nombre, leur caract??re r??p??titif ou
  syst??matique).</p><p>Pour vous aider dans votre d??marche, notamment si vous d??sirez exercer votre droit d???acc??s par le biais d???une
  demande ??crite ?? l???adresse postale mentionn??e au point 1, vous trouverez en cliquant sur le <a
  href=\"https://www.cnil.fr/fr/modele/courrier/exercer-son-droit-dacces\">lien</a> suivant un mod??le de courrier ??labor?? par la Commission
  Nationale de l???Informatique et des Libert??s (la ?? CNIL ??).</p><p><b>o Droit de rectification des donn??es</b></p><p>Au titre de ce droit,
  la l??gislation vous habilite ?? demander la rectification, la mise ?? jour, le verrouillage ou encore l???effacement des donn??es vous
  concernant qui peuvent s???av??rer le cas ??ch??ant inexactes, erron??es, incompl??tes ou obsol??tes.</p><p>Egalement, vous pouvez d??finir des
  directives g??n??rales et particuli??res relatives au sort des donn??es ?? caract??re personnel apr??s votre d??c??s. Le cas ??ch??ant, les h??ritiers
  d???une personne d??c??d??e peuvent exiger de prendre en consid??ration le d??c??s de leur proche et/ou de proc??der aux mises ?? jour n??cessaires.
  </p><p>Pour vous aider dans votre d??marche, notamment si vous d??sirez exercer, pour votre propre compte ou pour le compte de l???un de vos
  proches d??funt, votre droit de rectification par le biais d???une demande ??crite ?? l???adresse postale mentionn??e au point 1, vous trouverez
  en cliquant sur le <a href=\"https://www.cnil.fr/fr/modele/courrier/rectifier-des-donnees-inexactes-obsoletes-ou-perimees\">lien</a>
  suivant un mod??le de courrier ??labor?? par la CNIL.</p><p><b>o Droit d???opposition</b></p><p>L???exercice de ce droit n???est possible que dans
  l???une des deux situations suivantes :</p><p>Lorsque l???exercice de ce droit est fond?? sur des motifs l??gitimes ; ou</p><p>Lorsque
  l???exercice de ce droit vise ?? faire obstacle ?? ce que les donn??es recueillies soient utilis??es ?? des fins de prospection commerciale.</p>
  <p>Pour vous aider dans votre d??marche, notamment si vous d??sirez exercer votre droit d???opposition par le biais d???une demande ??crite
  adress??e ?? l???adresse postale indiqu??e au point 1, vous trouverez en cliquant sur le <a
  href=\"https://www.cnil.fr/fr/modele/courrier/supprimer-des-informations-vous-concernant-dun-site-internet\">lien</a> suivant un mod??le de
  courrier ??labor?? par la CNIL.</p><h4>6. D??lais de r??ponse</h4><p> _________ s???engage ?? r??pondre ?? votre demande d???acc??s, de rectification
  ou d???opposition ou toute autre demande compl??mentaire  d???informations dans un d??lai raisonnable qui ne saurait d??passer 1 mois ?? compter
  de la r??ception de votre demande.</p><h4>7. Prestataires habilit??s et transfert vers un pays tiers de l???Union Europ??enne</h4><p>_________
  vous informe qu???il a recours ?? ses prestataires habilit??s pour faciliter le recueil et le traitement des donn??es que vous nous avez
  communiqu??. Ces prestataires peuvent ??tre situ??s en dehors de  l???Union Europ??enne et ont communication des donn??es recueillies par le
  biais des divers formulaires pr??sents sur le Site.</p><p>_________ s???est pr??alablement assur?? de la mise en ??uvre par ses prestataires de
  garanties ad??quates et du respect de conditions strictes en mati??re de confidentialit??, d???usage et de protection des donn??es. Tout
  particuli??rement, la vigilance s???est port??e sur l???existence d???un fondement l??gal pour effectuer un quelconque transfert de donn??es vers un
  pays tiers. A ce titre, l???un de nos prestataires est soumis ?? (nom de la r??gle) _________ approuv??es par la (nom de l'autorit??) _________
  en (ann??e d'approbation)&nbsp;_________.</p><h4>8. Plainte aupr??s de l???autorit?? comp??tente</h4><p>Si vous consid??rez que _________ ne
  respecte pas ses obligations au regard de vos Informations Personnelles, vous pouvez adresser une plainte ou une demande aupr??s de
  l???autorit?? comp??tente. En France, l???autorit?? comp??tente est la CNIL ?? laquelle vous pouvez adresser une demande par voie ??lectronique en
  cliquant sur le lien suivant : <a href=\"https://www.cnil.fr/fr/plaintes/internet\">https://www.cnil.fr/fr/plaintes/internet</a>.</p>
  <h3>II. POLITIQUE RELATIVE AUX COOKIES</h3><p>Lors de votre premi??re connexion sur le site web de _________, vous ??tes avertis par un
  bandeau en bas de votre ??cran que des informations relatives ?? votre navigation sont susceptibles d?????tre enregistr??es dans des fichiers
  d??nomm??s ?? cookies ??. Notre politique d???utilisation des cookies vous permet de mieux comprendre les dispositions que nous mettons en ??uvre
  en mati??re de navigation sur notre site web. Elle vous informe notamment sur l???ensemble des cookies pr??sents sur notre site web, leur
  finalit?? (partie I.) et vous donne la marche ?? suivre pour les param??trer (partie II.)</p><h4>1. Informations g??n??rales sur les cookies
  pr??sents sur le site de _________</h4><p>_________, en tant qu?????diteur du pr??sent site web, pourra proc??der ?? l???implantation d???un cookie
  sur le disque dur de votre terminal (ordinateur, tablette, mobile etc.) afin de vous garantir une navigation fluide et optimale sur notre
  site Internet.</p><p>Les ?? cookies ?? (ou t??moins de connexion) sont des petits fichiers texte de taille limit??e qui nous permettent de
  reconna??tre votre ordinateur, votre tablette ou votre mobile aux fins de personnaliser les services que nous vous proposons.</p><p>Les
  informations recueillies par le biais des cookies ne permettent en aucune mani??re de vous identifier nominativement. Elles sont utilis??es
  exclusivement pour nos besoins propres afin d???am??liorer l???interactivit?? et la performance de notre site web et de vous adresser des
  contenus adapt??s ?? vos centres d???int??r??ts. Aucune de ces informations ne fait l???objet d???une communication aupr??s de tiers sauf lorsque
  _________ a obtenu au pr??alable votre consentement ou bien lorsque la divulgation de ces informations est requise par la loi, sur ordre
  d???un tribunal ou toute autorit?? administrative ou judiciaire habilit??e ?? en conna??tre.</p><p>Pour mieux vous ??clairer sur les informations
  que les cookies identifient, vous trouverez ci-dessous un tableau listant les diff??rents types de cookies susceptibles d?????tre utilis??s sur
  le site web de _________, leur nom, leur finalit?? ainsi que leur dur??e de conservation.</p><h4>2. Configuration de vos pr??f??rences sur les
  cookies</h4><p>Vous pouvez accepter ou refuser le d??p??t de cookies ?? tout moment.</p><p>Lors de votre premi??re connexion sur le site web
  de _________, une banni??re pr??sentant bri??vement des informations relatives au d??p??t de cookies et de technologies similaires appara??t en
  bas de votre ??cran. Cette banni??re vous demande de choisir explicitement d'acceptez ou non le d??p??t de cookies sur votre terminal.
  </p><p>Apr??s avoir fait votre choix, vous pouvez le modifier ult??rieurement&nbsp; en vous connectant ?? votre compte utilisateur puis en
  naviguant dans la section intitul??e ?? mes param??tres&nbsp;??, accessible via un clic sur votre nom, en haut ?? droite de l'??cran.</p>
  <p>Selon le type de cookie en cause, le recueil de votre consentement au d??p??t et ?? la lecture de cookies sur votre terminal peut ??tre
  imp??ratif.</p><h4>a. Les cookies exempt??s de consentement</h4><p>Conform??ment aux recommandations de la Commission Nationale de
  l???Informatique et des Libert??s (CNIL), certains cookies sont dispens??s du recueil pr??alable de votre consentement dans la mesure o?? ils
  sont strictement n??cessaires au fonctionnement du site internet ou ont pour finalit?? exclusive de permettre ou faciliter la communication
  par voie ??lectronique.  Il s???agit des cookies suivants :</p><p><b>o Identifiant de session</b> et&nbsp;<b>authentification</b> sur l'API.
  Ces cookies sont int??gralement soumis ?? la pr??sente politique dans la mesure o?? ils sont ??mis et g??r??s par _________.</p><p>
  <b>o Stripe</b>, permettant de g??rer les paiements par carte bancaire et dont la politique de confidentialit?? est accessible sur ce
  <a href=\"https://stripe.com/fr/privacy\">lien</a>.</p><p><b>o Disqus</b>, permettant de poster des commentaires sur les fiches projet et
  dont la politique de confidentialit?? est accessible sur ce <a href=\"https://help.disqus.com/articles/1717103-disqus-privacy-policy\">lien
  </a>.</p><h4>b. Les cookies n??cessitant le recueil pr??alable de votre consentement</h4><p>Cette
  exigence concerne les cookies ??mis par des tiers et qui sont qualifi??s de ?? persistants ?? dans la mesure o?? ils demeurent dans votre
  terminal jusqu????? leur effacement ou leur date d???expiration.</p><p>De tels cookies ??tant ??mis par des tiers, leur utilisation et leur d??p??t
  sont soumis ?? leurs propres politiques de confidentialit?? dont vous trouverez un lien ci-dessous. Cette famille de cookie comprend les
  cookies de mesure d???audience (Google Analytics).</p><p>Les cookies de mesure d???audience ??tablissent des statistiques concernant la
  fr??quentation et l???utilisation de divers ??l??ments du site web (comme les contenus/pages que vous avez visit??).
  Ces donn??es participent ?? l???am??lioration de l???ergonomie du site web de _________. Un outil de mesure d???audience est utilis?? sur le
  pr??sent site internet :</p><p><b>o Google Analytics</b> pour g??rer les statistiques de visites dont la politique de
  confidentialit?? est disponible (uniquement en anglais) ?? partir du <a href=\"https://policies.google.com/privacy?hl=fr&amp;gl=ZZ\">lien
  </a> suivant. </p><h4>c. Vous disposez de divers outils de param??trage des cookies</h4><p>La plupart
  des navigateurs Internet sont configur??s par d??faut de fa??on ?? ce que le d??p??t de cookies soit autoris??. Votre navigateur vous offre
  l???opportunit?? de modifier ces param??tres standards de mani??re ?? ce que l???ensemble des cookies soit rejet?? syst??matiquement ou bien ?? ce
  qu???une partie seulement des cookies soit accept??e ou refus??e en fonction de leur ??metteur.</p><p><b>ATTENTION</b> : Nous attirons votre
  attention sur le fait que le refus du d??p??t de cookies sur votre terminal est n??anmoins susceptible d???alt??rer votre exp??rience
  d???utilisateur ainsi que votre acc??s ?? certains services ou fonctionnalit??s du pr??sent site web. Le cas ??ch??ant, _________ d??cline toute
  responsabilit?? concernant les cons??quences li??es ?? la d??gradation de vos conditions de navigation qui interviennent en raison de votre
  choix de refuser, supprimer ou bloquer les cookies n??cessaires au fonctionnement du site.
  Ces cons??quences ne sauraient constituer un dommage et vous ne pourrez pr??tendre ?? aucune indemnit?? de ce fait.</p>
  <p>Votre navigateur vous permet ??galement de supprimer les cookies existants sur votre
  terminal ou encore de vous signaler lorsque de nouveaux cookies sont susceptibles d?????tre d??pos??s sur votre terminal. Ces param??tres n???ont
  pas d???incidence sur votre navigation mais vous font perdre tout le b??n??fice apport?? par le cookie.</p><p>Veuillez ci-dessous prendre
  connaissance des multiples outils mis ?? votre disposition afin que vous puissiez param??trer les cookies d??pos??s sur votre terminal.</p>
  <h4>d. Le param??trage de votre navigateur Internet</h4><p>Chaque navigateur Internet propose ses propres param??tres de gestion des
  cookies. Pour savoir de quelle mani??re modifier vos pr??f??rences en mati??re de cookies, vous trouverez ci-dessous les liens vers l???aide
  n??cessaire pour acc??der au menu de votre navigateur pr??vu ?? cet effet :</p>
  <ul>
    <li><a href=\"https://support.google.com/chrome/answer/95647?hl=fr\">Chrome</a></li>
    <li><a href=\"https://support.mozilla.org/fr/kb/activer-desactiver-cookies\">Firefox</a></li>
    <li><a href=\"https://support.microsoft.com/fr-fr/help/17442/windows-internet-explorer-delete-manage-cookies#ie=ie-11\">Internet
    Explorer</a></li>
    <li><a href=\"http://help.opera.com/Windows/10.20/fr/cookies.html\">Opera</a></li>
    <li><a href=\"https://support.apple.com/kb/PH21411?viewlocale=fr_FR&amp;locale=fr_FR\">Safari</a></li>
  </ul>
  <p>Pour de plus amples informations concernant les outils de ma??trise des cookies, vous pouvez consulter le
  <a href=\"https://www.cnil.fr/fr/cookies-les-outils-pour-les-maitriser\">site internet</a> de la CNIL.</p>"
  setting.save
end

if StatisticCustomAggregation.count.zero?
  # available reservations hours for machines
  machine_hours = StatisticType.find_by(key: 'hour', statistic_index_id: 2)

  available_hours = StatisticCustomAggregation.new(
    statistic_type_id: machine_hours.id,
    es_index: 'fablab',
    es_type: 'availabilities',
    field: 'available_hours',
    query: '{"size":0, "aggregations":{"%{aggs_name}":{"sum":{"field":"bookable_hours"}}}, "query":{"bool":{"must":[{"range":' \
           '{"start_at":{"gte":"%{start_date}", "lte":"%{end_date}"}}}, {"match":{"available_type":"machines"}}]}}}'
  )
  available_hours.save!

  # available training tickets
  training_bookings = StatisticType.find_by(key: 'booking', statistic_index_id: 3)

  available_tickets = StatisticCustomAggregation.new(
    statistic_type_id: training_bookings.id,
    es_index: 'fablab',
    es_type: 'availabilities',
    field: 'available_tickets',
    query: '{"size":0, "aggregations":{"%{aggs_name}":{"sum":{"field":"nb_total_places"}}}, "query":{"bool":{"must":[{"range":' \
           '{"start_at":{"gte":"%{start_date}", "lte":"%{end_date}"}}}, {"match":{"available_type":"training"}}]}}}'
  )
  available_tickets.save!
end

unless StatisticIndex.find_by(es_type_key: 'space')
  index = StatisticIndex.create!(es_type_key: 'space', label: I18n.t('statistics.spaces'))
  StatisticType.create!([
                          { statistic_index_id: index.id, key: 'booking', label: I18n.t('statistics.bookings'),
                            graph: true, simple: true },
                          { statistic_index_id: index.id, key: 'hour', label: I18n.t('statistics.hours_number'),
                            graph: true, simple: false }
                        ])
end
