import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flounder/state.dart';

void main() {
  group('Profile', () {
    test('Initialization with and without reminderAt', () {
      final profile1 = Profile(20, 5);
      expect(profile1.talkLength, 20);
      expect(profile1.discussionLength, 5);
      expect(profile1.reminderAt, 5); // Fallback to discussionLength

      final profile2 = Profile(20, 5, 2);
      expect(profile2.reminderAt, 2);
    });

    test('fromString', () {
      final profile = Profile.fromString('20-5-2');
      expect(profile.talkLength, 20);
      expect(profile.discussionLength, 5);
      expect(profile.reminderAt, 2);
    });

    test('toString', () {
      final profile = Profile(20, 5, 2);
      expect(profile.toString(), '20-5-2');
    });

    test('key', () {
      final profile = Profile(20, 5, 2);
      expect(profile.key(), '20+5 (2)');
    });

    test('clone', () {
      final profile = Profile(20, 5, 2);
      final cloned = profile.clone();
      expect(cloned.talkLength, 20);
      expect(cloned.discussionLength, 5);
      expect(cloned.reminderAt, 2);
      expect(identical(profile, cloned), false);
    });
  });

  group('ProfileCollection', () {
    test('Initialization', () {
      final collection = ProfileCollection();
      expect(collection.isEmpty(), true);

      final collectionFrom = ProfileCollection.from([Profile(20, 5), Profile(10, 2)]);
      expect(collectionFrom.isEmpty(), false);
      expect(collectionFrom.keys().length, 2);
    });

    test('add and at', () {
      final collection = ProfileCollection();
      final profile = Profile(20, 5);
      collection.add(profile);

      expect(collection.includes(profile.key()), true);
      expect(collection.at(profile.key()).talkLength, 20);
    });

    test('first', () {
      final collection = ProfileCollection();
      expect(collection.first().talkLength, 0);

      collection.add(Profile(20, 5));
      collection.add(Profile(10, 2));
      expect(collection.first().talkLength, 20);
    });

    test('remove', () {
      final collection = ProfileCollection();
      final profile = Profile(20, 5);
      collection.add(profile);
      expect(collection.includes(profile.key()), true);

      collection.remove(profile.key());
      expect(collection.includes(profile.key()), false);
    });

    test('swap', () {
      final collection1 = ProfileCollection.from([Profile(20, 5)]);
      final collection2 = ProfileCollection.from([Profile(10, 2), Profile(15, 3)]);

      collection1.swap(collection2);
      expect(collection1.keys().length, 2);
      expect(collection1.includes('10+2 (2)'), true);
    });

    test('export', () {
      final collection = ProfileCollection.from([Profile(20, 5, 2)]);
      final exported = collection.export();
      expect(exported, ['20-5-2']);
    });
  });

  group('ApplicationState', () {
    test('Initialization', () {
      final state = ApplicationState();
      expect(state.timer, 0);
      expect(state.isPaused, false);
      expect(state.mode.id, ModeRegister.IDLE.id);
      expect(state.presets.isEmpty(), true);
      expect(state.profile.talkLength, 0);
    });

    test('reset', () {
      final state = ApplicationState();
      state.profile = Profile(20, 5);
      state.isPaused = true;
      state.reset();

      expect(state.timer, 1200); // 20 * 60
      expect(state.isPaused, false);
    });
  });
}
