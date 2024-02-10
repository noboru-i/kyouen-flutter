import 'package:flutter/material.dart';

class StagePage extends StatelessWidget {
  const StagePage({super.key});

  static const routeName = '/stage';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          _Body(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text('前へ'),
        ),
        const Expanded(
          child: Text('STAGE: 1'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('前へ'),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.green,
      ),
    );
  }
}
