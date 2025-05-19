// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myChatsHash() => r'f63d4a79da1e6a735dd4a7aa91fb4b8ca6f468cb';

/// Kullanıcının aktif chatlerini sağlar
///
/// Copied from [myChats].
@ProviderFor(myChats)
final myChatsProvider = AutoDisposeStreamProvider<List<ChatModel>>.internal(
  myChats,
  name: r'myChatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myChatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyChatsRef = AutoDisposeStreamProviderRef<List<ChatModel>>;
String _$messagesHash() => r'bd44bbd1bd7a4e17c440e7b050a84b84443389c5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Belirli bir chat oturumundaki mesajları sağlar
///
/// Copied from [messages].
@ProviderFor(messages)
const messagesProvider = MessagesFamily();

/// Belirli bir chat oturumundaki mesajları sağlar
///
/// Copied from [messages].
class MessagesFamily extends Family<AsyncValue<List<MessageModel>>> {
  /// Belirli bir chat oturumundaki mesajları sağlar
  ///
  /// Copied from [messages].
  const MessagesFamily();

  /// Belirli bir chat oturumundaki mesajları sağlar
  ///
  /// Copied from [messages].
  MessagesProvider call(
    String chatId,
  ) {
    return MessagesProvider(
      chatId,
    );
  }

  @override
  MessagesProvider getProviderOverride(
    covariant MessagesProvider provider,
  ) {
    return call(
      provider.chatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesProvider';
}

/// Belirli bir chat oturumundaki mesajları sağlar
///
/// Copied from [messages].
class MessagesProvider extends AutoDisposeStreamProvider<List<MessageModel>> {
  /// Belirli bir chat oturumundaki mesajları sağlar
  ///
  /// Copied from [messages].
  MessagesProvider(
    String chatId,
  ) : this._internal(
          (ref) => messages(
            ref as MessagesRef,
            chatId,
          ),
          from: messagesProvider,
          name: r'messagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesHash,
          dependencies: MessagesFamily._dependencies,
          allTransitiveDependencies: MessagesFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  MessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  Override overrideWith(
    Stream<List<MessageModel>> Function(MessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesProvider._internal(
        (ref) => create(ref as MessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MessageModel>> createElement() {
    return _MessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesRef on AutoDisposeStreamProviderRef<List<MessageModel>> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _MessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<MessageModel>>
    with MessagesRef {
  _MessagesProviderElement(super.provider);

  @override
  String get chatId => (origin as MessagesProvider).chatId;
}

String _$chatControllerHash() => r'021cffe609b717d35c32a9ac1d8a56820f127a44';

/// Chat işlemlerini yöneten controller
///
/// Copied from [ChatController].
@ProviderFor(ChatController)
final chatControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChatController, void>.internal(
  ChatController.new,
  name: r'chatControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
