import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/widgets/modern_back_button.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBodyColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Navigator.of(context).canPop()
              ? const ModernBackButton()
              : null,
          title: const Text(
            'سياسة الخصوصية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: kAppBarColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'آخر تحديث: 22 يناير 2026',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'مرحبًا بكم في تطبيق رحيل. نحن نلتزم بحماية خصوصيتك وبياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك عند استخدام خدماتنا.',
                style: TextStyle(fontSize: 16, height: 1.8),
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                '1. المعلومات التي نجمعها',
                [
                  _buildSubSection(
                    '1.1 المعلومات الشخصية',
                    'عند التسجيل في تطبيق رحيل، قد نجمع المعلومات التالية:',
                    [
                      'الاسم الأول والأخير',
                      'رقم الهاتف المحمول',
                      'عنوان البريد الإلكتروني',
                      'نوع الحساب (قائد مركبة أو راكب)',
                    ],
                  ),
                  _buildSubSection(
                    '1.2 معلومات الرحلات',
                    'لتسهيل عملية الربط بين قائدي المركبات والركاب، نجمع:',
                    [
                      'تفاصيل الرحلة (الوجهة، التاريخ، الوقت، نقطة الالتقاء)',
                      'عدد المقاعد المتاحة أو المطلوبة',
                      'حالة الحجز',
                    ],
                  ),
                  _buildSubSection(
                    '1.3 معلومات الاستخدام',
                    'قد نجمع معلومات حول كيفية استخدامك للتطبيق، بما في ذلك:',
                    [
                      'معلومات الجهاز (نوع الجهاز، نظام التشغيل)',
                      'سجلات الاستخدام والأخطاء',
                      'تفضيلات التطبيق',
                    ],
                  ),
                ],
              ),
              
              _buildSection(
                '2. كيفية استخدام معلوماتك',
                [
                  const Text(
                    'نستخدم المعلومات التي نجمعها للأغراض التالية:',
                    style: TextStyle(fontSize: 16, height: 1.8),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletList([
                    'توفير وتحسين خدمات التطبيق',
                    'تسهيل عملية الربط بين قائدي المركبات والركاب',
                    'إرسال إشعارات حول الرحلات والحجوزات',
                    'التواصل معك بخصوص التحديثات والتغييرات في الخدمة',
                    'تحليل وتحسين تجربة المستخدم',
                    'ضمان أمان وسلامة المستخدمين',
                    'الامتثال للمتطلبات القانونية والتنظيمية',
                  ]),
                ],
              ),
              
              _buildSection(
                '3. مشاركة المعلومات',
                [
                  _buildSubSection(
                    '3.1 مع المستخدمين الآخرين',
                    'عند حجز رحلة، يتم مشاركة معلوماتك الأساسية (الاسم، رقم الهاتف) مع الطرف الآخر (قائد المركبة أو الراكب) لتسهيل عملية التواصل والتنسيق.',
                    [],
                  ),
                  _buildSubSection(
                    '3.2 مع مقدمي الخدمات',
                    'قد نشارك معلوماتك مع مقدمي خدمات موثوقين يساعدوننا في تشغيل التطبيق، مثل:',
                    [
                      'خدمات الاستضافة والتخزين السحابي (Supabase)',
                      'خدمات التحليلات',
                      'خدمات إرسال الإشعارات',
                    ],
                  ),
                  _buildSubSection(
                    '3.3 للامتثال القانوني',
                    'قد نكشف عن معلوماتك إذا كان ذلك مطلوبًا بموجب القانون أو استجابة لطلبات قانونية صحيحة من السلطات.',
                    [],
                  ),
                ],
              ),
              
              _buildSection(
                '4. أمان البيانات',
                [
                  const Text(
                    'نتخذ إجراءات أمنية معقولة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو الكشف أو التعديل أو التدمير، بما في ذلك:',
                    style: TextStyle(fontSize: 16, height: 1.8),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletList([
                    'تشفير البيانات أثناء النقل والتخزين',
                    'المصادقة الآمنة للمستخدمين',
                    'مراقبة الوصول إلى البيانات',
                    'تحديثات أمنية منتظمة',
                  ]),
                ],
              ),
              
              _buildSection(
                '5. حقوقك',
                [
                  const Text(
                    'لديك الحق في:',
                    style: TextStyle(fontSize: 16, height: 1.8),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletList([
                    'الوصول: طلب نسخة من بياناتك الشخصية',
                    'التصحيح: تحديث أو تصحيح معلوماتك',
                    'الحذف: طلب حذف حسابك وبياناتك',
                    'الاعتراض: الاعتراض على معالجة معينة لبياناتك',
                    'نقل البيانات: طلب نسخة من بياناتك بصيغة قابلة للنقل',
                  ]),
                ],
              ),
              
              _buildSection(
                '6. الاحتفاظ بالبيانات',
                [
                  const Text(
                    'نحتفظ بمعلوماتك الشخصية طالما كان حسابك نشطًا أو حسب الحاجة لتقديم خدماتنا. بعد حذف حسابك، سنحذف أو نجعل بياناتك مجهولة الهوية، باستثناء ما يتطلبه القانون للاحتفاظ به.',
                    style: TextStyle(fontSize: 16, height: 1.8),
                  ),
                ],
              ),
              
              _buildSection(
                '7. خصوصية الأطفال',
                [
                  const Text(
                    'تطبيق رحيل غير موجه للأطفال دون سن 18 عامًا. لا نجمع عن قصد معلومات شخصية من الأطفال. إذا اكتشفنا أننا جمعنا معلومات من طفل، سنتخذ خطوات لحذف تلك المعلومات.',
                    style: TextStyle(fontSize: 16, height: 1.8),
                  ),
                ],
              ),
              
              _buildSection(
                '8. التغييرات على سياسة الخصوصية',
                [
                  const Text(
                    'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنخطرك بأي تغييرات جوهرية عن طريق نشر السياسة الجديدة في التطبيق وتحديث تاريخ "آخر تحديث" أعلاه. ننصحك بمراجعة هذه الصفحة بشكل دوري.',
                    style: TextStyle(fontSize: 16, height: 1.8),
                  ),
                ],
              ),
              
              _buildSection(
                '9. طبيعة الخدمة',
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ملاحظة هامة:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'تطبيق رحيل يعمل كمنصة إعلانية فقط لربط قائدي المركبات بالركاب. نحن لا:',
                          style: TextStyle(fontSize: 16, height: 1.8),
                        ),
                        const SizedBox(height: 8),
                        _buildBulletList([
                          'نتتبع الرحلات الفعلية',
                          'نتحمل مسؤولية عن تكلفة النقل أو الترتيبات المالية بين الأطراف',
                          'نضمن جودة الخدمة أو سلامة الرحلات',
                          'نتدخل في الاتفاقيات بين قائدي المركبات والركاب',
                        ]),
                        const SizedBox(height: 8),
                        const Text(
                          'المستخدمون مسؤولون عن التواصل والتنسيق والترتيبات المالية فيما بينهم.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAppBarColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kAppBarColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'تواصل معنا',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAppBarColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'إذا كانت لديك أي أسئلة أو استفسارات حول سياسة الخصوصية هذه، يرجى الاتصال بنا:',
                      style: TextStyle(fontSize: 16, height: 1.8),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'البريد الإلكتروني: raheelcorp@outlook.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: kAppBarColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kAppBarColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubSection(String title, String description, List<String> bullets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 16, height: 1.8),
        ),
        if (bullets.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildBulletList(bullets),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
