import 'package:flutter/material.dart';

class ContentModerationScreen extends StatelessWidget {
	const ContentModerationScreen({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: ListView(
				padding: const EdgeInsets.all(16),
				children: const [
					Text('Content Moderation', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
					SizedBox(height: 12),
					Text('Review and moderate reported content, events, and posts.'),
				],
			),
		);
	}
}
