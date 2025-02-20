export const STATS = ["Strength", "Agility", "Health"];
export const UNIT_TAGS = ["Infantry", "Cavalry", "Archer"];
export const EFFECT_NAMES = [
  "Cannot be frozen",
  "Cannot be stunned",
  "Cannot be silenced",
  "Increase global damage",
];
export const ITEM_NAMES = [
  "Long Sword",
  "Katana",
  "Sombrero",
  "Beret",
  "Snake Earrings",
  "Diamond Earrings",
];

export const IMAGE_URIS = [
  "https://ipfs.io/ipfs/QmR4JReUxLLcb9sKGG2qBAvPY9Tcrt6xLTx74PEnesgfim?filename=test-2.svg",
  "https://ipfs.io/ipfs/QmUmXHWGqyyF1q5ga1DNGF1ceuS2bRvENudNWodGrUPtAD?filename=test.svg",
  "https://ipfs.io/ipfs/QmUmXHWGqyyF1q5ga1DNGF1ceuS2bRvENudNWodGrUPtAD?filename=test.svg",
  "https://ipfs.io/ipfs/QmUmXHWGqyyF1q5ga1DNGF1ceuS2bRvENudNWodGrUPtAD?filename=test.svg",
  "https://ipfs.io/ipfs/QmUmXHWGqyyF1q5ga1DNGF1ceuS2bRvENudNWodGrUPtAD?filename=test.svg",
  "https://ipfs.io/ipfs/QmUmXHWGqyyF1q5ga1DNGF1ceuS2bRvENudNWodGrUPtAD?filename=test.svg",
];

export const RARITIES = ["Common", "Uncommon", "Rare", "Epic", "Legendary"];

export const CATEGORIES = ["Weapon", "Hat", "Earrings"];
export const POWERS = ["Low", "Medium", "High", "Signature"];

export const LABELS = [
  ...STATS,
  ...UNIT_TAGS,
  ...EFFECT_NAMES,
  ...ITEM_NAMES,
  ...IMAGE_URIS,
  ...RARITIES,
  ...CATEGORIES,
  ...POWERS,
];

export const LABEL_START_INDEX = {
  stat: { from: 0, to: 3 },
  unit: { from: 3, to: 6 },
  effect: { from: 6, to: 10 },
  name: { from: 10, to: 16 },
  imageURI: { from: 16, to: 22 },
  rarity: { from: 22, to: 27 },
  category: { from: 27, to: 30 },
  power: { from: 30, to: 34 },
};

export const EFFECTS = [
  {
    nameId: EFFECT_NAMES.indexOf("Cannot be frozen"),
    multiplier: 0,
  },
  {
    nameId: EFFECT_NAMES.indexOf("Cannot be stunned"),
    multiplier: 0,
  },
  {
    nameId: EFFECT_NAMES.indexOf("Cannot be silenced"),
    multiplier: 0,
  },
  {
    nameId: EFFECT_NAMES.indexOf("Increase global damage"),
    multiplier: 105,
  },
  {
    nameId: EFFECT_NAMES.indexOf("Increase global damage"),
    multiplier: 110,
  },
];

export const BUFFS = [
  {
    statId: STATS.indexOf("Strength"),
    unitTagId: UNIT_TAGS.indexOf("Infantry"),
    isFlat: true,
    multiplier: 10,
  },
  {
    statId: STATS.indexOf("Agility"),
    unitTagId: UNIT_TAGS.indexOf("Cavalry"),
    isFlat: true,
    multiplier: 10,
  },
  {
    statId: STATS.indexOf("Health"),
    unitTagId: UNIT_TAGS.indexOf("Archer"),
    isFlat: true,
    multiplier: 10,
  },
  {
    statId: STATS.indexOf("Strength"),
    unitTagId: UNIT_TAGS.indexOf("Cavalry"),
    isFlat: false,
    multiplier: 110,
  },
  {
    statId: STATS.indexOf("Agility"),
    unitTagId: UNIT_TAGS.indexOf("Archer"),
    isFlat: false,
    multiplier: 110,
  },
  {
    statId: STATS.indexOf("Health"),
    unitTagId: UNIT_TAGS.indexOf("Infantry"),
    isFlat: false,
    multiplier: 110,
  },
];

export const ITEM_DATAS: {
  categoryId: number;
  powerId: number;
  effectIds: [number, number, number, number];
  buffIds: [
    number,
    number,
    number,
    number,
    number,
    number,
    number,
    number,
    number,
    number,
    number,
  ];
}[] = [
  {
    categoryId: CATEGORIES.indexOf("Weapon"),
    powerId: POWERS.indexOf("Low"),
    effectIds: [0, 65535, 0, 0],
    buffIds: [0, 1, 2, 65535, 0, 0, 0, 0, 0, 0, 0],
  },
  {
    categoryId: CATEGORIES.indexOf("Hat"),
    powerId: POWERS.indexOf("Medium"),
    effectIds: [1, 2, 65535, 0],
    buffIds: [3, 4, 65535, 0, 0, 0, 0, 0, 0, 0, 0],
  },
  {
    categoryId: CATEGORIES.indexOf("Earrings"),
    powerId: POWERS.indexOf("High"),
    effectIds: [2, 65535, 0, 0],
    buffIds: [0, 1, 2, 65535, 0, 0, 0, 0, 0, 0, 0],
  },
  {
    categoryId: CATEGORIES.indexOf("Weapon"),
    powerId: POWERS.indexOf("Signature"),
    effectIds: [0, 1, 65535, 0],
    buffIds: [1, 3, 5, 65535, 0, 0, 0, 0, 0, 0, 0],
  },
  {
    categoryId: CATEGORIES.indexOf("Hat"),
    powerId: POWERS.indexOf("Signature"),
    effectIds: [1, 2, 65535, 0],
    buffIds: [3, 4, 5, 65535, 0, 0, 0, 0, 0, 0, 0],
  },
  {
    categoryId: CATEGORIES.indexOf("Earrings"),
    powerId: POWERS.indexOf("Signature"),
    effectIds: [3, 4, 65535, 0],
    buffIds: [0, 1, 5, 65535, 0, 0, 0, 0, 0, 0, 0],
  },
];

export const ITEM_TYPES = [
  {
    nameId: ITEM_NAMES.indexOf("Long Sword"),
    imageURIId: 0,
    rarityId: RARITIES.indexOf("Common"),
    itemDataId: 0,
  },
  {
    nameId: ITEM_NAMES.indexOf("Katana"),
    imageURIId: 1,
    rarityId: RARITIES.indexOf("Uncommon"),
    itemDataId: 1,
  },
  {
    nameId: ITEM_NAMES.indexOf("Sombrero"),
    imageURIId: 2,
    rarityId: RARITIES.indexOf("Rare"),
    itemDataId: 2,
  },
  {
    nameId: ITEM_NAMES.indexOf("Beret"),
    imageURIId: 3,
    rarityId: RARITIES.indexOf("Epic"),
    itemDataId: 3,
  },
  {
    nameId: ITEM_NAMES.indexOf("Snake Earrings"),
    imageURIId: 4,
    rarityId: RARITIES.indexOf("Legendary"),
    itemDataId: 4,
  },
  {
    nameId: ITEM_NAMES.indexOf("Diamond Earrings"),
    imageURIId: 5,
    rarityId: RARITIES.indexOf("Legendary"),
    itemDataId: 5,
  },
];

export const ITEMS = [
  {
    bonus: 23,
    itemTypeId: 0,
  },
  {
    bonus: 23,
    itemTypeId: 1,
  },
  {
    bonus: 23,
    itemTypeId: 2,
  },
  {
    bonus: 23,
    itemTypeId: 3,
  },
  {
    bonus: 23,
    itemTypeId: 4,
  },
  {
    bonus: 23,
    itemTypeId: 5,
  },
];
